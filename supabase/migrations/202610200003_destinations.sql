-- REVIEW DRAFT: do not execute without explicit database approval.
-- Supabase PostgreSQL 17+, run as the trusted migration owner.
begin;

create table public.locations (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 160),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  province text, district text,
  latitude numeric(9,6) check (latitude between -90 and 90),
  longitude numeric(9,6) check (longitude between -180 and 180),
  aliases text[] not null default '{}'
);
create table public.destinations (
  id uuid primary key default gen_random_uuid(),
  location_id uuid references public.locations(id) on delete restrict,
  name text not null check (char_length(btrim(name)) between 1 and 160),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  short_description text not null default '' check (char_length(short_description)<=500),
  description text not null default '' check (char_length(description)<=30000),
  min_days integer not null check (min_days>0),
  max_days integer not null check (max_days>=min_days),
  published boolean not null default false,
  planning_notes jsonb not null default '{}' check (jsonb_typeof(planning_notes)='object'),
  last_verified_at timestamptz,
  verified_by uuid references public.profiles(id) on delete restrict,
  source_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index destination_location_idx on public.destinations(location_id);
create index destination_published_duration_idx on public.destinations(min_days,max_days) where published;
create index destination_search_idx on public.destinations using gin (to_tsvector('simple',name || ' ' || short_description));
create table public.destination_media (
  id uuid primary key default gen_random_uuid(),
  destination_id uuid not null references public.destinations(id) on delete restrict,
  url text not null check (url ~ '^https://[^[:space:]]+$'),
  alt_text text not null check (char_length(btrim(alt_text))>0),
  credit text not null, license text not null, source_note text not null,
  role text not null check (role in ('hero','gallery')),
  sort_order integer not null check (sort_order>=0),
  unique(destination_id,sort_order)
);
create unique index destination_one_hero_idx on public.destination_media(destination_id) where role='hero';
create table public.interests (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$')
);
create table public.destination_interests (
  destination_id uuid not null references public.destinations(id) on delete restrict,
  interest_id uuid not null references public.interests(id) on delete restrict,
  weight numeric(4,3) not null default 1 check (weight between 0 and 1),
  primary key(destination_id,interest_id)
);
create index destination_interest_reverse_idx on public.destination_interests(interest_id,destination_id);
create table public.destination_seasons (
  destination_id uuid not null references public.destinations(id) on delete restrict,
  month integer not null check (month between 1 and 12),
  suitability text not null check (suitability in ('recommended','possible','avoid','unknown')),
  notes text not null default '',
  last_verified_at timestamptz, verified_by uuid references public.profiles(id) on delete restrict, source_note text,
  primary key(destination_id,month)
);
create table public.attractions (
  id uuid primary key default gen_random_uuid(),
  destination_id uuid not null references public.destinations(id) on delete restrict,
  name text not null, description text not null default '',
  cost_min_minor bigint check (cost_min_minor>=0),
  cost_max_minor bigint,
  currency text not null default 'NPR' check (currency='NPR'),
  cost_basis text not null default 'per_person' check (cost_basis in ('per_person','per_group')),
  published boolean not null default false,
  last_verified_at timestamptz, verified_by uuid references public.profiles(id) on delete restrict, source_note text,
  check ((cost_min_minor is null and cost_max_minor is null) or
         (cost_min_minor is not null and cost_max_minor is not null and cost_max_minor>=cost_min_minor))
);
create index attraction_destination_idx on public.attractions(destination_id);
create table public.activities (
  id uuid primary key default gen_random_uuid(),
  destination_id uuid not null references public.destinations(id) on delete restrict,
  name text not null, description text not null default '',
  duration_minutes integer check (duration_minutes>0),
  cost_min_minor bigint check (cost_min_minor>=0), cost_max_minor bigint,
  currency text not null default 'NPR' check (currency='NPR'),
  cost_basis text not null default 'per_person' check (cost_basis in ('per_person','per_group')),
  published boolean not null default false,
  last_verified_at timestamptz, verified_by uuid references public.profiles(id) on delete restrict, source_note text,
  check ((cost_min_minor is null and cost_max_minor is null) or
         (cost_min_minor is not null and cost_max_minor is not null and cost_max_minor>=cost_min_minor))
);
create index activity_destination_idx on public.activities(destination_id);
create table public.transport_routes (
  id uuid primary key default gen_random_uuid(),
  origin_id uuid not null references public.locations(id) on delete restrict,
  destination_id uuid not null references public.destinations(id) on delete restrict,
  mode text not null,
  duration_min_minutes integer not null check (duration_min_minutes>0),
  duration_max_minutes integer not null check (duration_max_minutes>=duration_min_minutes),
  cost_min_minor bigint not null check (cost_min_minor>=0),
  cost_max_minor bigint not null check (cost_max_minor>=cost_min_minor),
  currency text not null default 'NPR' check (currency='NPR'),
  basis text not null check (basis in ('per_person','per_vehicle')),
  capacity integer check (capacity>0),
  return_included boolean not null default false,
  last_verified_at timestamptz, verified_by uuid references public.profiles(id) on delete restrict, source_note text,
  check (basis<>'per_vehicle' or capacity is not null)
);
create index transport_origin_destination_idx on public.transport_routes(origin_id,destination_id,mode);
create index transport_destination_idx on public.transport_routes(destination_id);
create table public.destination_costs (
  id uuid primary key default gen_random_uuid(),
  destination_id uuid not null references public.destinations(id) on delete restrict,
  category text not null check (category in ('accommodation','food','activity','permit','misc')),
  min_minor bigint not null check (min_minor>=0), max_minor bigint not null check (max_minor>=min_minor),
  currency text not null default 'NPR' check (currency='NPR'),
  unit text not null check (unit in ('person','group','room','vehicle')),
  frequency text not null check (frequency in ('trip','day','night')),
  capacity integer check (capacity>0),
  valid_from date, valid_until date,
  last_verified_at timestamptz, verified_by uuid references public.profiles(id) on delete restrict, source_note text,
  check (unit not in ('room','vehicle') or capacity is not null),
  check (valid_from is null or valid_until is null or valid_from<=valid_until)
);
create index destination_cost_lookup_idx on public.destination_costs(destination_id,category);
create trigger destinations_touch before update on public.destinations for each row execute function private.touch_updated_at();
alter table public.locations enable row level security;
revoke all on table public.locations from public,anon,authenticated,service_role;
grant select,insert,update on public.locations to authenticated;
create policy locations_admin on public.locations for all to authenticated using (private.is_admin()) with check (private.is_admin());
alter table public.destinations enable row level security;
revoke all on table public.destinations from public,anon,authenticated,service_role;
grant select,insert,update on public.destinations to authenticated;
create policy destinations_admin on public.destinations for all to authenticated using (private.is_admin()) with check (private.is_admin());
alter table public.destination_media enable row level security;
revoke all on table public.destination_media from public,anon,authenticated,service_role;
grant select,insert,update on public.destination_media to authenticated;
create policy destination_media_admin on public.destination_media for all to authenticated using (private.is_admin()) with check (private.is_admin());
alter table public.interests enable row level security;
revoke all on table public.interests from public,anon,authenticated,service_role;
grant select,insert,update on public.interests to authenticated;
create policy interests_admin on public.interests for all to authenticated using (private.is_admin()) with check (private.is_admin());
alter table public.destination_interests enable row level security;
revoke all on table public.destination_interests from public,anon,authenticated,service_role;
grant select,insert,update on public.destination_interests to authenticated;
create policy destination_interests_admin on public.destination_interests for all to authenticated using (private.is_admin()) with check (private.is_admin());
alter table public.destination_seasons enable row level security;
revoke all on table public.destination_seasons from public,anon,authenticated,service_role;
grant select,insert,update on public.destination_seasons to authenticated;
create policy destination_seasons_admin on public.destination_seasons for all to authenticated using (private.is_admin()) with check (private.is_admin());
alter table public.attractions enable row level security;
revoke all on table public.attractions from public,anon,authenticated,service_role;
grant select,insert,update on public.attractions to authenticated;
create policy attractions_admin on public.attractions for all to authenticated using (private.is_admin()) with check (private.is_admin());
alter table public.activities enable row level security;
revoke all on table public.activities from public,anon,authenticated,service_role;
grant select,insert,update on public.activities to authenticated;
create policy activities_admin on public.activities for all to authenticated using (private.is_admin()) with check (private.is_admin());
alter table public.transport_routes enable row level security;
revoke all on table public.transport_routes from public,anon,authenticated,service_role;
grant select,insert,update on public.transport_routes to authenticated;
create policy transport_routes_admin on public.transport_routes for all to authenticated using (private.is_admin()) with check (private.is_admin());
alter table public.destination_costs enable row level security;
revoke all on table public.destination_costs from public,anon,authenticated,service_role;
grant select,insert,update on public.destination_costs to authenticated;
create policy destination_costs_admin on public.destination_costs for all to authenticated using (private.is_admin()) with check (private.is_admin());
-- Public destination reads are safe projection RPCs in migration 006.
commit;
