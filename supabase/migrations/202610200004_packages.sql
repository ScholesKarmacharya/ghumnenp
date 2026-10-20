-- REVIEW DRAFT: do not execute without explicit database approval.
-- Supabase PostgreSQL 17+, run as the trusted migration owner.
begin;

set local search_path = public, extensions, pg_catalog;
create table public.packages (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid not null references public.agencies(id) on delete restrict,
  slug text not null check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and char_length(slug)<=100),
  state text not null default 'draft' check (state in ('draft','published','paused','archived')),
  published_revision_id uuid,
  reconfirmed_revision_id uuid,
  last_reconfirmed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(id,agency_id), unique(agency_id,slug),
  check (state<>'published' or (published_revision_id is not null and reconfirmed_revision_id is not null and reconfirmed_revision_id=published_revision_id and last_reconfirmed_at is not null))
);
create index package_tenant_state_idx on public.packages(agency_id,state);
create table public.package_revisions (
  id uuid primary key default gen_random_uuid(),
  package_id uuid not null,
  agency_id uuid not null,
  version integer not null check (version>0),
  status text not null default 'draft' check (status in ('draft','pending_review','approved','rejected')),
  title text not null check (char_length(btrim(title)) between 1 and 200),
  description text not null default '' check (char_length(description)<=30000),
  duration_days integer not null check (duration_days between 1 and 365),
  nights integer not null check (nights>=0 and nights<duration_days),
  min_travelers integer not null check (min_travelers between 1 and 10000),
  max_travelers integer not null check (max_travelers>=min_travelers and max_travelers<=10000),
  transport text, travel_style text,
  booking_url text check (booking_url is null or booking_url ~ '^https://[^[:space:]]+$'),
  inclusions text[] not null default '{}', exclusions text[] not null default '{}',
  necessary_exclusions_unpriced boolean not null default true,
  reviewed_by uuid references public.profiles(id) on delete restrict,
  reviewed_at timestamptz,
  source_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(package_id,version), unique(id,agency_id), unique(id,package_id,agency_id),
  foreign key(package_id,agency_id) references public.packages(id,agency_id) on delete restrict,
  check (status<>'approved' or (reviewed_by is not null and reviewed_at is not null))
);
alter table public.packages add constraint published_revision_tenant_fk foreign key(published_revision_id,id,agency_id)
references public.package_revisions(id,package_id,agency_id) on delete restrict;
alter table public.packages add constraint reconfirmed_revision_tenant_fk foreign key(reconfirmed_revision_id,id,agency_id)
references public.package_revisions(id,package_id,agency_id) on delete restrict;
create index revision_tenant_status_idx on public.package_revisions(agency_id,status);
create index revision_duration_group_idx on public.package_revisions(duration_days,min_travelers,max_travelers);
create table public.package_destinations (
  revision_id uuid not null, agency_id uuid not null,
  destination_id uuid not null references public.destinations(id) on delete restrict,
  stop_order integer not null check (stop_order>=0),
  is_primary boolean not null default false,
  primary key(revision_id,destination_id), unique(revision_id,stop_order),
  foreign key(revision_id,agency_id) references public.package_revisions(id,agency_id) on delete restrict
);
create unique index package_primary_destination_idx on public.package_destinations(revision_id) where is_primary;
create index package_destination_reverse_idx on public.package_destinations(destination_id,revision_id);
create table public.package_origins (
  revision_id uuid not null, agency_id uuid not null,
  location_id uuid not null references public.locations(id) on delete restrict,
  primary key(revision_id,location_id),
  foreign key(revision_id,agency_id) references public.package_revisions(id,agency_id) on delete restrict
);
create index package_origin_reverse_idx on public.package_origins(location_id,revision_id);
create table public.package_interests (
  revision_id uuid not null, agency_id uuid not null,
  interest_id uuid not null references public.interests(id) on delete restrict,
  primary key(revision_id,interest_id),
  foreign key(revision_id,agency_id) references public.package_revisions(id,agency_id) on delete restrict
);
create index package_interest_reverse_idx on public.package_interests(interest_id,revision_id);
create table public.package_itinerary_days (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null, agency_id uuid not null,
  day_number integer not null check (day_number>0),
  title text not null, notes text not null default '',
  unique(revision_id,day_number), unique(id,revision_id,agency_id),
  foreign key(revision_id,agency_id) references public.package_revisions(id,agency_id) on delete restrict
);
create table public.package_itinerary_items (
  id uuid primary key default gen_random_uuid(),
  day_id uuid not null, revision_id uuid not null, agency_id uuid not null,
  sort_order integer not null check (sort_order>=0),
  title text not null, notes text not null default '',
  activity_id uuid references public.activities(id) on delete restrict,
  destination_id uuid references public.destinations(id) on delete restrict,
  unique(day_id,sort_order),
  foreign key(day_id,revision_id,agency_id) references public.package_itinerary_days(id,revision_id,agency_id) on delete restrict
);
create index itinerary_item_revision_idx on public.package_itinerary_items(revision_id);
create table public.package_price_rules (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null, agency_id uuid not null,
  basis text not null check (basis in ('per_person','per_group')),
  base_minor bigint not null check (base_minor between 0 and 9000000000000000),
  currency text not null default 'NPR' check (currency='NPR'),
  min_travelers integer not null check (min_travelers between 1 and 10000),
  max_travelers integer not null check (max_travelers>=min_travelers and max_travelers<=10000),
  travel_from date, travel_until date,
  sales_from timestamptz not null, sales_until timestamptz not null,
  last_verified_at timestamptz not null default now(),
  source_note text not null check (char_length(btrim(source_note))>0),
  group_scope int4range generated always as (int4range(min_travelers,max_travelers,'[]')) stored,
  travel_scope daterange generated always as (daterange(travel_from,travel_until,'[]')) stored,
  sales_scope tstzrange generated always as (tstzrange(sales_from,sales_until,'[)')) stored,
  unique(id,revision_id,agency_id),
  foreign key(revision_id,agency_id) references public.package_revisions(id,agency_id) on delete restrict,
  check (travel_from is null or travel_until is null or travel_from<=travel_until),
  check ((travel_from is null or isfinite(travel_from)) and (travel_until is null or isfinite(travel_until))),
  check (isfinite(sales_from) and isfinite(sales_until) and sales_from<sales_until),
  exclude using gist (revision_id with =,group_scope with &&,travel_scope with &&,sales_scope with &&)
);
create index price_rule_tenant_idx on public.package_price_rules(agency_id,revision_id);
create table public.package_price_components (
  id uuid primary key default gen_random_uuid(),
  price_rule_id uuid not null, revision_id uuid not null, agency_id uuid not null,
  label text not null check (char_length(btrim(label)) between 1 and 200),
  classification text not null check (classification in ('included','mandatory','optional')),
  amount_minor bigint check (amount_minor between 0 and 9000000000000000),
  unit text not null check (unit in ('person','group')),
  frequency text not null check (frequency in ('trip','day','night')),
  foreign key(price_rule_id,revision_id,agency_id) references public.package_price_rules(id,revision_id,agency_id) on delete restrict
);
create index price_component_rule_idx on public.package_price_components(price_rule_id);
create table public.package_availability (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null, agency_id uuid not null,
  kind text not null check (kind in ('fixed_departure','operating_window')),
  starts_on date not null, ends_on date not null,
  travel_scope daterange generated always as (daterange(starts_on,ends_on,'[]')) stored,
  status text not null check (status in ('open','on_request','closed','sold_out')),
  remaining_travelers integer check (remaining_travelers>=0),
  confirmed_at timestamptz,
  confirmed_by uuid references public.profiles(id) on delete restrict,
  source_note text not null check (char_length(btrim(source_note))>0),
  updated_at timestamptz not null default now(),
  unique(id,revision_id,agency_id),
  foreign key(revision_id,agency_id) references public.package_revisions(id,agency_id) on delete restrict,
  check (isfinite(starts_on) and isfinite(ends_on) and starts_on<=ends_on),
  check (status<>'open' or (confirmed_at is not null and confirmed_by is not null)),
  exclude using gist (revision_id with =,travel_scope with &&)
);
create index availability_tenant_idx on public.package_availability(agency_id,revision_id);
create table public.package_media (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null, agency_id uuid not null,
  url text not null check (url ~ '^https://[^[:space:]]+$'),
  alt_text text not null check (char_length(btrim(alt_text)) between 1 and 500),
  credit text not null, license text not null,
  sort_order integer not null check (sort_order>=0),
  unique(revision_id,sort_order),
  foreign key(revision_id,agency_id) references public.package_revisions(id,agency_id) on delete restrict
);
create table public.package_review_records (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null, agency_id uuid not null,
  decision text not null check (decision in ('approved','rejected')),
  reviewer_id uuid not null references public.profiles(id) on delete restrict,
  -- Keep the same full-text limit as audit_logs; never silently trim reasons.
  reason text not null check (char_length(btrim(reason))>=1 and char_length(reason)<=2000),
  request_id uuid not null unique, created_at timestamptz not null default now(),
  foreign key(revision_id,agency_id) references public.package_revisions(id,agency_id) on delete restrict
);
create index package_review_revision_idx on public.package_review_records(revision_id);

create function private.revision_is_draft(p_revision uuid,p_agency uuid) returns boolean
language sql stable security definer set search_path = ''
as $fn$
  select exists(select 1 from public.package_revisions where id=p_revision and agency_id=p_agency and status='draft')
    and private.is_agency_member(p_agency);
$fn$;
revoke all on function private.revision_is_draft(uuid,uuid) from public,anon,authenticated,service_role;
grant execute on function private.revision_is_draft(uuid,uuid) to authenticated;

create function private.guard_revision_child() returns trigger
language plpgsql security definer set search_path = ''
as $fn$
declare v_revision uuid; v_agency uuid; v_status text;
begin
  if tg_op='UPDATE' and (new.revision_id<>old.revision_id or new.agency_id<>old.agency_id) then
    raise exception 'Cannot reparent revision data' using errcode='23514';
  end if;
  if tg_op='DELETE' then v_revision:=old.revision_id; v_agency:=old.agency_id;
  else v_revision:=new.revision_id; v_agency:=new.agency_id; end if;
  -- Serialize with moderation, preventing an edit racing an approval.
  select status into v_status from public.package_revisions where id=v_revision and agency_id=v_agency for update;
  if v_status is distinct from 'draft' then raise exception 'Only draft content can change' using errcode='23514'; end if;
  if tg_op='DELETE' then return old; end if;
  return new;
end;
$fn$;
revoke all on function private.guard_revision_child() from public,anon,authenticated,service_role;
create function private.guard_revision_update() returns trigger
language plpgsql set search_path = ''
as $fn$
begin
  if old.status='approved' or old.id<>new.id or old.package_id<>new.package_id or old.agency_id<>new.agency_id or old.version<>new.version then
    raise exception 'Approved revision or identity is immutable' using errcode='23514';
  end if;
  return new;
end;
$fn$;
revoke all on function private.guard_revision_update() from public,anon,authenticated,service_role;
create trigger revision_guard before update on public.package_revisions for each row execute function private.guard_revision_update();
create trigger package_touch before update on public.packages for each row execute function private.touch_updated_at();
create trigger revision_touch before update on public.package_revisions for each row execute function private.touch_updated_at();
create trigger review_immutable before update or delete on public.package_review_records for each row execute function private.immutable_record();
alter table public.packages enable row level security;
revoke all on table public.packages from public,anon,authenticated,service_role;
grant select on public.packages to authenticated;
create policy packages_read on public.packages for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
alter table public.package_revisions enable row level security;
revoke all on table public.package_revisions from public,anon,authenticated,service_role;
grant select on public.package_revisions to authenticated;
create policy package_revisions_read on public.package_revisions for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
alter table public.package_destinations enable row level security;
revoke all on table public.package_destinations from public,anon,authenticated,service_role;
grant select on public.package_destinations to authenticated;
create policy package_destinations_read on public.package_destinations for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
alter table public.package_origins enable row level security;
revoke all on table public.package_origins from public,anon,authenticated,service_role;
grant select on public.package_origins to authenticated;
create policy package_origins_read on public.package_origins for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
alter table public.package_interests enable row level security;
revoke all on table public.package_interests from public,anon,authenticated,service_role;
grant select on public.package_interests to authenticated;
create policy package_interests_read on public.package_interests for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
alter table public.package_itinerary_days enable row level security;
revoke all on table public.package_itinerary_days from public,anon,authenticated,service_role;
grant select on public.package_itinerary_days to authenticated;
create policy package_itinerary_days_read on public.package_itinerary_days for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
alter table public.package_itinerary_items enable row level security;
revoke all on table public.package_itinerary_items from public,anon,authenticated,service_role;
grant select on public.package_itinerary_items to authenticated;
create policy package_itinerary_items_read on public.package_itinerary_items for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
alter table public.package_price_rules enable row level security;
revoke all on table public.package_price_rules from public,anon,authenticated,service_role;
grant select on public.package_price_rules to authenticated;
create policy package_price_rules_read on public.package_price_rules for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
alter table public.package_price_components enable row level security;
revoke all on table public.package_price_components from public,anon,authenticated,service_role;
grant select on public.package_price_components to authenticated;
create policy package_price_components_read on public.package_price_components for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
alter table public.package_availability enable row level security;
revoke all on table public.package_availability from public,anon,authenticated,service_role;
grant select on public.package_availability to authenticated;
create policy package_availability_read on public.package_availability for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
alter table public.package_review_records enable row level security;
revoke all on table public.package_review_records from public,anon,authenticated,service_role;
grant select on public.package_review_records to authenticated;
create policy package_review_records_read on public.package_review_records for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
alter table public.package_media enable row level security;
revoke all on table public.package_media from public,anon,authenticated,service_role;
grant select,insert,update,delete on public.package_media to authenticated;
create policy package_media_read on public.package_media for select to authenticated using (private.is_admin() or private.is_agency_member(agency_id));
create policy package_media_draft_write on public.package_media for all to authenticated using (private.revision_is_draft(revision_id,agency_id)) with check (private.revision_is_draft(revision_id,agency_id));
create trigger package_media_draft_guard before insert or update or delete on public.package_media for each row execute function private.guard_revision_child();
-- Status, tenant IDs, published pointers and confirmation times are RPC-only.
grant insert(package_id,agency_id,version,title,description,duration_days,nights,min_travelers,max_travelers,transport,travel_style,booking_url,inclusions,exclusions,necessary_exclusions_unpriced,source_note)
on public.package_revisions to authenticated;
grant update(title,description,duration_days,nights,min_travelers,max_travelers,transport,travel_style,booking_url,inclusions,exclusions,necessary_exclusions_unpriced,source_note)
on public.package_revisions to authenticated;
create policy revision_insert on public.package_revisions for insert to authenticated with check (status='draft' and private.is_agency_member(agency_id));
create policy revision_edit on public.package_revisions for update to authenticated using (status='draft' and private.is_agency_member(agency_id)) with check (status='draft' and private.is_agency_member(agency_id));
grant insert,update,delete on public.package_destinations to authenticated;
create policy package_destinations_draft_write on public.package_destinations for all to authenticated using (private.revision_is_draft(revision_id,agency_id)) with check (private.revision_is_draft(revision_id,agency_id));
create trigger package_destinations_draft_guard before insert or update or delete on public.package_destinations for each row execute function private.guard_revision_child();
grant insert,update,delete on public.package_origins to authenticated;
create policy package_origins_draft_write on public.package_origins for all to authenticated using (private.revision_is_draft(revision_id,agency_id)) with check (private.revision_is_draft(revision_id,agency_id));
create trigger package_origins_draft_guard before insert or update or delete on public.package_origins for each row execute function private.guard_revision_child();
grant insert,update,delete on public.package_interests to authenticated;
create policy package_interests_draft_write on public.package_interests for all to authenticated using (private.revision_is_draft(revision_id,agency_id)) with check (private.revision_is_draft(revision_id,agency_id));
create trigger package_interests_draft_guard before insert or update or delete on public.package_interests for each row execute function private.guard_revision_child();
grant insert,update,delete on public.package_itinerary_days to authenticated;
create policy package_itinerary_days_draft_write on public.package_itinerary_days for all to authenticated using (private.revision_is_draft(revision_id,agency_id)) with check (private.revision_is_draft(revision_id,agency_id));
create trigger package_itinerary_days_draft_guard before insert or update or delete on public.package_itinerary_days for each row execute function private.guard_revision_child();
grant insert,update,delete on public.package_itinerary_items to authenticated;
create policy package_itinerary_items_draft_write on public.package_itinerary_items for all to authenticated using (private.revision_is_draft(revision_id,agency_id)) with check (private.revision_is_draft(revision_id,agency_id));
create trigger package_itinerary_items_draft_guard before insert or update or delete on public.package_itinerary_items for each row execute function private.guard_revision_child();
grant insert,update,delete on public.package_price_rules to authenticated;
create policy package_price_rules_draft_write on public.package_price_rules for all to authenticated using (private.revision_is_draft(revision_id,agency_id)) with check (private.revision_is_draft(revision_id,agency_id));
create trigger package_price_rules_draft_guard before insert or update or delete on public.package_price_rules for each row execute function private.guard_revision_child();
grant insert,update,delete on public.package_price_components to authenticated;
create policy package_price_components_draft_write on public.package_price_components for all to authenticated using (private.revision_is_draft(revision_id,agency_id)) with check (private.revision_is_draft(revision_id,agency_id));
create trigger package_price_components_draft_guard before insert or update or delete on public.package_price_components for each row execute function private.guard_revision_child();
commit;
