-- REVIEW DRAFT: do not execute without explicit database approval.
-- Supabase PostgreSQL 17+, run as the trusted migration owner.
begin;

create schema private;
revoke all on schema private from public, anon, authenticated, service_role;
grant usage on schema private to authenticated;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete restrict,
  display_name text not null default '' check (char_length(display_name) <= 100),
  avatar_url text check (avatar_url is null or avatar_url ~ '^https://[^[:space:]]+$'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.user_roles (
  user_id uuid not null references public.profiles(id) on delete restrict,
  role text not null check (role in ('traveler','agency','admin')),
  granted_by uuid references public.profiles(id) on delete restrict,
  granted_at timestamptz not null default now(),
  primary key (user_id,role)
);
create table public.marketplace_settings (
  singleton boolean primary key default true check (singleton),
  package_reconfirmation_days integer not null default 30 check (package_reconfirmation_days between 1 and 365),
  inquiries_enabled boolean not null default false,
  updated_at timestamptz not null default now()
);
insert into public.marketplace_settings(singleton) values (true);
create table public.retention_policies (
  data_category text primary key check (data_category in ('inquiries','verification','events','audit','abuse_keys','operations','profiles','trips')),
  retain_days integer check (retain_days > 0),
  purge_enabled boolean not null default false,
  policy_note text not null default '',
  updated_at timestamptz not null default now(),
  check (not purge_enabled or retain_days is not null)
);
-- Configuration only: no final retention periods or deletion job are invented.
insert into public.retention_policies(data_category)
values ('inquiries'),('verification'),('events'),('audit'),('abuse_keys'),('operations'),('profiles'),('trips');
create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id) on delete restrict,
  agency_id uuid,
  action text not null,
  target_table text not null,
  target_id uuid,
  -- Match agency/package moderation records; never truncate a review reason.
  reason text check (char_length(reason) <= 2000),
  metadata jsonb not null default '{}' check (jsonb_typeof(metadata)='object'),
  created_at timestamptz not null default now()
);
create index audit_logs_tenant_time_idx on public.audit_logs(agency_id,created_at desc);
create index audit_logs_actor_idx on public.audit_logs(actor_id) where actor_id is not null;

create function private.is_admin() returns boolean
language sql volatile security definer set search_path = ''
as $fn$
  select exists (select 1 from public.user_roles where user_id=(select auth.uid()) and role='admin');
$fn$;
revoke all on function private.is_admin() from public, anon, authenticated, service_role;
grant execute on function private.is_admin() to authenticated;

create function private.require_admin() returns void
language plpgsql security definer set search_path = ''
as $fn$
begin
  if auth.uid() is null or not private.is_admin() then
    raise exception 'Administrator authorization required' using errcode='42501';
  end if;
end;
$fn$;
revoke all on function private.require_admin() from public, anon, authenticated, service_role;

create function private.touch_updated_at() returns trigger
language plpgsql set search_path = ''
as $fn$
begin
  new.updated_at := clock_timestamp();
  return new;
end;
$fn$;
revoke all on function private.touch_updated_at() from public, anon, authenticated, service_role;
create trigger profiles_touch before update on public.profiles for each row execute function private.touch_updated_at();

create function private.bootstrap_profile() returns trigger
language plpgsql security definer set search_path = ''
as $fn$
begin
  -- Do not trust raw_user_meta_data for roles, tenant IDs or public profile data.
  insert into public.profiles(id) values (new.id) on conflict (id) do nothing;
  insert into public.user_roles(user_id,role) values (new.id,'traveler') on conflict do nothing;
  return new;
end;
$fn$;
revoke all on function private.bootstrap_profile() from public, anon, authenticated, service_role;
create trigger ghumne_profile_created after insert on auth.users
for each row execute function private.bootstrap_profile();

create function private.write_audit(p_action text,p_table text,p_target uuid,p_agency uuid,p_reason text default null)
returns void language sql security definer set search_path = ''
as $fn$
  insert into public.audit_logs(actor_id,agency_id,action,target_table,target_id,reason)
  values (auth.uid(),p_agency,p_action,p_table,p_target,p_reason);
$fn$;
revoke all on function private.write_audit(text,text,uuid,uuid,text) from public, anon, authenticated, service_role;
alter table public.profiles enable row level security;
revoke all on table public.profiles from public, anon, authenticated, service_role;
alter table public.user_roles enable row level security;
revoke all on table public.user_roles from public, anon, authenticated, service_role;
alter table public.marketplace_settings enable row level security;
revoke all on table public.marketplace_settings from public, anon, authenticated, service_role;
alter table public.retention_policies enable row level security;
revoke all on table public.retention_policies from public, anon, authenticated, service_role;
alter table public.audit_logs enable row level security;
revoke all on table public.audit_logs from public, anon, authenticated, service_role;
grant select on public.profiles,public.user_roles to authenticated;
grant update(display_name,avatar_url) on public.profiles to authenticated;
create policy profile_read on public.profiles for select to authenticated using (id=(select auth.uid()) or private.is_admin());
create policy profile_update on public.profiles for update to authenticated using (id=(select auth.uid())) with check (id=(select auth.uid()));
create policy role_read on public.user_roles for select to authenticated using (user_id=(select auth.uid()) or private.is_admin());
grant select,update on public.marketplace_settings,public.retention_policies to authenticated;
create policy settings_admin on public.marketplace_settings for all to authenticated using (private.is_admin()) with check (private.is_admin());
create policy retention_admin on public.retention_policies for all to authenticated using (private.is_admin()) with check (private.is_admin());
grant select on public.audit_logs to authenticated;
create policy audit_admin_read on public.audit_logs for select to authenticated using (private.is_admin());
-- No API role can insert/update/delete role grants or audit records directly.
commit;
