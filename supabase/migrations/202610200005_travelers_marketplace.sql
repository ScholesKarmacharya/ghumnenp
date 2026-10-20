-- REVIEW DRAFT: do not execute without explicit database approval.
-- Supabase PostgreSQL 17+, run as the trusted migration owner.
begin;

create table public.trips (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete restrict,
  destination_id uuid references public.destinations(id) on delete restrict,
  origin_id uuid references public.locations(id) on delete restrict,
  title text not null check (char_length(btrim(title)) between 1 and 200),
  days integer not null check (days between 1 and 365),
  nights integer not null check (nights>=0 and nights<days),
  travelers integer not null check (travelers between 1 and 10000),
  budget_total_minor bigint check (budget_total_minor between 0 and 9000000000000000),
  currency text not null default 'NPR' check (currency='NPR'),
  start_date date, end_date date,
  visibility text not null default 'private' check (visibility in ('private','unlisted')),
  estimate_snapshot jsonb not null default '{}' check (jsonb_typeof(estimate_snapshot)='object'),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(id,user_id),
  check ((start_date is null and end_date is null) or
    (start_date is not null and end_date is not null and end_date-start_date+1=days))
);
create index trip_owner_time_idx on public.trips(user_id,updated_at desc);
create index trip_destination_idx on public.trips(destination_id);
create index trip_origin_idx on public.trips(origin_id);
create table public.trip_days (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null, user_id uuid not null,
  day_number integer not null check (day_number>0),
  title text not null, notes text not null default '',
  unique(trip_id,day_number), unique(id,trip_id,user_id),
  foreign key(trip_id,user_id) references public.trips(id,user_id) on delete restrict
);
create table public.trip_items (
  id uuid primary key default gen_random_uuid(),
  day_id uuid not null, trip_id uuid not null, user_id uuid not null,
  sort_order integer not null check (sort_order>=0),
  title text not null, private_notes text not null default '',
  activity_id uuid references public.activities(id) on delete restrict,
  attraction_id uuid references public.attractions(id) on delete restrict,
  destination_id uuid references public.destinations(id) on delete restrict,
  estimate_min_minor bigint check (estimate_min_minor>=0),
  estimate_max_minor bigint,
  unique(day_id,sort_order),
  foreign key(day_id,trip_id,user_id) references public.trip_days(id,trip_id,user_id) on delete restrict,
  check ((estimate_min_minor is null and estimate_max_minor is null) or
    (estimate_min_minor is not null and estimate_max_minor is not null and estimate_max_minor>=estimate_min_minor))
);
create index trip_item_owner_trip_idx on public.trip_items(user_id,trip_id);
create table public.favorites (
  user_id uuid not null references public.profiles(id) on delete restrict,
  destination_id uuid not null references public.destinations(id) on delete restrict,
  created_at timestamptz not null default now(),
  primary key(user_id,destination_id)
);
create table public.trip_shares (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null, user_id uuid not null,
  token_hash text not null unique check (token_hash ~ '^[a-f0-9]{64}$'),
  expires_at timestamptz, revoked_at timestamptz,
  created_at timestamptz not null default now(),
  foreign key(trip_id,user_id) references public.trips(id,user_id) on delete restrict
);
create index trip_share_owner_idx on public.trip_shares(user_id,trip_id);
create table public.trip_package_comparisons (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null, user_id uuid not null,
  package_id uuid not null, revision_id uuid not null, agency_id uuid not null,
  input_snapshot jsonb not null check (jsonb_typeof(input_snapshot)='object'),
  quote_snapshot jsonb not null check (jsonb_typeof(quote_snapshot)='object'),
  computed_at timestamptz not null default now(),
  request_id uuid not null unique,
  foreign key(trip_id,user_id) references public.trips(id,user_id) on delete restrict,
  foreign key(revision_id,package_id,agency_id) references public.package_revisions(id,package_id,agency_id) on delete restrict
);
create index comparison_owner_trip_idx on public.trip_package_comparisons(user_id,trip_id);
create index comparison_revision_idx on public.trip_package_comparisons(revision_id);
create table public.inquiries (
  id uuid primary key default gen_random_uuid(),
  package_id uuid not null, revision_id uuid not null, agency_id uuid not null,
  user_id uuid references public.profiles(id) on delete restrict,
  contact_name text not null check (char_length(btrim(contact_name)) between 1 and 100),
  contact_email text check (contact_email is null or char_length(contact_email) between 3 and 254),
  contact_phone text check (contact_phone is null or (char_length(contact_phone) between 6 and 40 and contact_phone ~ '^[+]?[0-9][0-9 ()-]+$')),
  message text not null default '' check (char_length(message)<=4000),
  consent_version text not null check (char_length(btrim(consent_version)) between 1 and 100),
  consent_at timestamptz not null default now(),
  travelers integer not null check (travelers between 1 and 10000),
  starts_on date,
  quote_snapshot jsonb not null check (jsonb_typeof(quote_snapshot)='object'),
  status text not null default 'new' check (status in ('new','contacted','closed')),
  request_id uuid not null unique,
  request_fingerprint text not null,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  foreign key(revision_id,package_id,agency_id) references public.package_revisions(id,package_id,agency_id) on delete restrict,
  check (contact_email is not null or contact_phone is not null)
);
create index inquiry_tenant_inbox_idx on public.inquiries(agency_id,status,created_at desc);
create index inquiry_traveler_idx on public.inquiries(user_id,created_at desc) where user_id is not null;
create index inquiry_revision_idx on public.inquiries(revision_id);
create table public.inquiry_rate_limits (
  abuse_key_hash text not null check (abuse_key_hash ~ '^[a-f0-9]{64}$'),
  window_start timestamptz not null,
  attempts integer not null check (attempts>0),
  primary key(abuse_key_hash,window_start)
);
create table public.featured_placements (
  id uuid primary key default gen_random_uuid(),
  package_id uuid not null, agency_id uuid not null,
  surface text not null check (surface in ('home','search','destination')),
  destination_id uuid references public.destinations(id) on delete restrict,
  starts_at timestamptz not null, ends_at timestamptz not null,
  status text not null check (status in ('active','paused','expired')),
  label text not null default 'Sponsored' check (label='Sponsored'),
  approved_by uuid not null references public.profiles(id) on delete restrict,
  request_id uuid not null unique,
  created_at timestamptz not null default now(),
  unique(id,package_id,agency_id),
  foreign key(package_id,agency_id) references public.packages(id,agency_id) on delete restrict,
  check (isfinite(starts_at) and isfinite(ends_at) and starts_at<ends_at),
  check ((surface='destination' and destination_id is not null) or (surface<>'destination' and destination_id is null))
);
create index placement_surface_window_idx on public.featured_placements(surface,starts_at,ends_at) where status='active';
create index placement_tenant_package_idx on public.featured_placements(agency_id,package_id);
create table public.marketplace_events (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null,
  package_id uuid not null,
  placement_id uuid,
  event_type text not null check (event_type in ('package_view','website_click','whatsapp_click','inquiry')),
  source text not null check (source in ('organic','sponsored')),
  request_id uuid not null unique,
  created_at timestamptz not null default now(),
  foreign key(package_id,agency_id) references public.packages(id,agency_id) on delete restrict,
  foreign key(placement_id,package_id,agency_id) references public.featured_placements(id,package_id,agency_id) on delete restrict,
  check ((source='sponsored' and placement_id is not null) or (source='organic' and placement_id is null))
);
create index event_tenant_time_idx on public.marketplace_events(agency_id,created_at);
create trigger trip_touch before update on public.trips for each row execute function private.touch_updated_at();
create trigger inquiry_touch before update on public.inquiries for each row execute function private.touch_updated_at();
alter table public.trips enable row level security;
revoke all on table public.trips from public,anon,authenticated,service_role;
alter table public.trip_days enable row level security;
revoke all on table public.trip_days from public,anon,authenticated,service_role;
alter table public.trip_items enable row level security;
revoke all on table public.trip_items from public,anon,authenticated,service_role;
alter table public.favorites enable row level security;
revoke all on table public.favorites from public,anon,authenticated,service_role;
alter table public.trip_shares enable row level security;
revoke all on table public.trip_shares from public,anon,authenticated,service_role;
alter table public.trip_package_comparisons enable row level security;
revoke all on table public.trip_package_comparisons from public,anon,authenticated,service_role;
alter table public.inquiries enable row level security;
revoke all on table public.inquiries from public,anon,authenticated,service_role;
alter table public.inquiry_rate_limits enable row level security;
revoke all on table public.inquiry_rate_limits from public,anon,authenticated,service_role;
alter table public.featured_placements enable row level security;
revoke all on table public.featured_placements from public,anon,authenticated,service_role;
alter table public.marketplace_events enable row level security;
revoke all on table public.marketplace_events from public,anon,authenticated,service_role;
grant select,insert,update,delete on public.trips to authenticated;
create policy trips_owner on public.trips for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
grant select,insert,update,delete on public.trip_days to authenticated;
create policy trip_days_owner on public.trip_days for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
grant select,insert,update,delete on public.trip_items to authenticated;
create policy trip_items_owner on public.trip_items for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
grant select,insert,update,delete on public.favorites to authenticated;
create policy favorites_owner on public.favorites for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
-- Share and comparison records are written only by controlled RPCs.
grant select on public.trip_shares,public.trip_package_comparisons to authenticated;
create policy share_owner_read on public.trip_shares for select to authenticated using (user_id=(select auth.uid()));
create policy comparison_owner_read on public.trip_package_comparisons for select to authenticated using (user_id=(select auth.uid()));
grant select on public.inquiries to authenticated;
create policy inquiry_read on public.inquiries for select to authenticated using (user_id=(select auth.uid()) or private.is_admin() or private.is_agency_member(agency_id));
grant select on public.featured_placements to authenticated;
create policy placement_read on public.featured_placements for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
-- No raw event/abuse-key reads and no direct inquiry/placement mutation grants.
commit;
