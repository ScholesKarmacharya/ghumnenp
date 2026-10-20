-- REVIEW DRAFT: do not execute without explicit database approval.
-- Supabase PostgreSQL 17+, run as the trusted migration owner.
begin;

create schema if not exists extensions;
create extension if not exists btree_gist with schema extensions;
-- Do not relocate an existing extension automatically.
do $check$
begin
  if not exists (
    select 1 from pg_catalog.pg_extension e join pg_catalog.pg_namespace n on n.oid=e.extnamespace
    where e.extname='btree_gist' and n.nspname='extensions'
  ) then raise exception 'Review btree_gist extension schema before applying'; end if;
end;
$check$;
set local search_path = public, extensions, pg_catalog;

create table public.agencies (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 2 and 160),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and char_length(slug)<=100),
  description text not null default '' check (char_length(description)<=10000),
  website_url text check (website_url is null or website_url ~ '^https://[^[:space:]]+$'),
  public_email text check (public_email is null or char_length(public_email)<=254),
  public_phone text check (public_phone is null or char_length(public_phone)<=40),
  whatsapp text check (whatsapp is null or whatsapp ~ '^[1-9][0-9]{6,14}$'),
  approval_status text not null default 'pending' check (approval_status in ('pending','approved','rejected')),
  operational_status text not null default 'active' check (operational_status in ('active','suspended','archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.agency_memberships (
  agency_id uuid not null references public.agencies(id) on delete restrict,
  user_id uuid not null references public.profiles(id) on delete restrict,
  role text not null default 'owner' check (role='owner'),
  status text not null default 'active' check (status in ('active','revoked')),
  created_at timestamptz not null default now(),
  primary key(agency_id,user_id)
);
create unique index agency_one_owner_idx on public.agency_memberships(agency_id) where status='active';
create index agency_member_lookup_idx on public.agency_memberships(user_id,agency_id) where status='active';
create table public.agency_verifications (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete restrict,
  submitted_by uuid not null references public.profiles(id) on delete restrict,
  business_registration_reference text check (char_length(business_registration_reference)<=200),
  -- Private bucket reference only; never a public document URL.
  evidence_storage_path text check (char_length(evidence_storage_path)<=500),
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  reviewed_by uuid references public.profiles(id) on delete restrict,
  reviewed_at timestamptz,
  review_note text check (char_length(review_note)<=2000),
  created_at timestamptz not null default now(),
  unique(id,agency_id),
  check ((status='pending' and reviewed_by is null and reviewed_at is null) or
         (status<>'pending' and reviewed_by is not null and reviewed_at is not null))
);
create index agency_verification_tenant_idx on public.agency_verifications(agency_id,created_at desc);
create table public.agency_approval_records (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete restrict,
  verification_id uuid,
  decision text not null check (decision in ('approved','rejected','suspended','reactivated')),
  reviewer_id uuid not null references public.profiles(id) on delete restrict,
  -- Count the full stored text, as verification notes and audit reasons do.
  reason text not null check (char_length(btrim(reason))>=1 and char_length(reason)<=2000),
  request_id uuid not null unique,
  created_at timestamptz not null default now(),
  foreign key(verification_id,agency_id) references public.agency_verifications(id,agency_id) on delete restrict
);
create index agency_approval_tenant_idx on public.agency_approval_records(agency_id,created_at desc);
alter table public.audit_logs add constraint audit_agency_fk foreign key(agency_id) references public.agencies(id) on delete restrict;

create table public.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[a-z0-9_]+$'),
  name text not null check (char_length(btrim(name)) between 1 and 100),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
create table public.subscription_plan_versions (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.subscription_plans(id) on delete restrict,
  version integer not null check (version>0),
  billing_model text not null check (billing_model in ('free_pilot','monthly','annual')),
  price_minor bigint check (price_minor between 0 and 9000000000000000),
  currency text not null default 'NPR' check (currency='NPR'),
  can_publish boolean not null,
  max_published_packages integer check (max_published_packages>=0),
  analytics_level text not null default 'none' check (analytics_level in ('none','basic','advanced')),
  can_sponsor boolean not null default false,
  max_active_placements integer not null default 0 check (max_active_placements>=0),
  created_at timestamptz not null default now(),
  unique(plan_id,version),
  check (billing_model<>'free_pilot' or (price_minor is not null and price_minor=0)),
  check (can_sponsor or max_active_placements=0)
);
-- Null prices are configurable/unpriced drafts, never inferred to be free.
create table public.agency_subscriptions (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete restrict,
  plan_version_id uuid not null references public.subscription_plan_versions(id) on delete restrict,
  status text not null check (status in ('pending','active','suspended','expired','cancelled')),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  active_period tstzrange generated always as (tstzrange(starts_at,ends_at,'[)')) stored,
  assigned_by uuid not null references public.profiles(id) on delete restrict,
  reason text not null check (char_length(btrim(reason)) between 1 and 1000),
  request_id uuid not null unique,
  created_at timestamptz not null default now(),
  check (isfinite(starts_at) and isfinite(ends_at) and starts_at<ends_at),
  exclude using gist (agency_id with =,active_period with &&) where (status='active')
);
create index agency_subscription_lookup_idx on public.agency_subscriptions(agency_id,status,ends_at);
create index agency_subscription_plan_idx on public.agency_subscriptions(plan_version_id);
create table public.subscription_change_requests (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete restrict,
  requested_plan_version_id uuid not null references public.subscription_plan_versions(id) on delete restrict,
  requested_by uuid not null references public.profiles(id) on delete restrict,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  request_id uuid not null unique,
  created_at timestamptz not null default now()
);
create index subscription_request_tenant_idx on public.subscription_change_requests(agency_id,status);

create function private.is_agency_member(p_agency uuid) returns boolean
language sql volatile security definer set search_path = ''
as $fn$
  select exists (
    select 1 from public.agency_memberships m join public.user_roles r on r.user_id=m.user_id and r.role='agency'
    where m.agency_id=p_agency and m.user_id=(select auth.uid()) and m.status='active'
  );
$fn$;
revoke all on function private.is_agency_member(uuid) from public,anon,authenticated,service_role;
grant execute on function private.is_agency_member(uuid) to authenticated;

create function private.require_agency(p_agency uuid) returns void
language plpgsql security definer set search_path = ''
as $fn$
begin
  if auth.uid() is null or not (private.is_admin() or private.is_agency_member(p_agency)) then
    raise exception 'Agency authorization required' using errcode='42501';
  end if;
end;
$fn$;
revoke all on function private.require_agency(uuid) from public,anon,authenticated,service_role;

create function private.immutable_record() returns trigger
language plpgsql set search_path = ''
as $fn$
begin raise exception 'Append-only record' using errcode='23514'; end;
$fn$;
revoke all on function private.immutable_record() from public,anon,authenticated,service_role;
create trigger plan_version_immutable before update or delete on public.subscription_plan_versions for each row execute function private.immutable_record();
create trigger approval_record_immutable before update or delete on public.agency_approval_records for each row execute function private.immutable_record();
create trigger audit_record_immutable before update or delete on public.audit_logs for each row execute function private.immutable_record();
create trigger agencies_touch before update on public.agencies for each row execute function private.touch_updated_at();
alter table public.agencies enable row level security;
revoke all on table public.agencies from public,anon,authenticated,service_role;
grant select on public.agencies to authenticated;
alter table public.agency_memberships enable row level security;
revoke all on table public.agency_memberships from public,anon,authenticated,service_role;
grant select on public.agency_memberships to authenticated;
alter table public.agency_verifications enable row level security;
revoke all on table public.agency_verifications from public,anon,authenticated,service_role;
grant select on public.agency_verifications to authenticated;
alter table public.agency_approval_records enable row level security;
revoke all on table public.agency_approval_records from public,anon,authenticated,service_role;
grant select on public.agency_approval_records to authenticated;
alter table public.subscription_plans enable row level security;
revoke all on table public.subscription_plans from public,anon,authenticated,service_role;
grant select on public.subscription_plans to authenticated;
alter table public.subscription_plan_versions enable row level security;
revoke all on table public.subscription_plan_versions from public,anon,authenticated,service_role;
grant select on public.subscription_plan_versions to authenticated;
alter table public.agency_subscriptions enable row level security;
revoke all on table public.agency_subscriptions from public,anon,authenticated,service_role;
grant select on public.agency_subscriptions to authenticated;
alter table public.subscription_change_requests enable row level security;
revoke all on table public.subscription_change_requests from public,anon,authenticated,service_role;
grant select on public.subscription_change_requests to authenticated;
create policy agency_read on public.agencies for select to authenticated using (private.is_admin() or private.is_agency_member(id));
create policy membership_read on public.agency_memberships for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
create policy verification_read on public.agency_verifications for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
create policy approval_read on public.agency_approval_records for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
create policy plan_read on public.subscription_plans for select to authenticated using (true);
create policy plan_version_read on public.subscription_plan_versions for select to authenticated using (true);
create policy subscription_read on public.agency_subscriptions for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
create policy subscription_request_read on public.subscription_change_requests for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
-- No direct writes to approval, membership, subscription or plan-version state.
commit;
