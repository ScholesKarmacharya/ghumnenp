-- REVIEW DRAFT: do not execute without explicit database approval.
-- Supabase PostgreSQL 17+, run as the trusted migration owner.
begin;

alter table public.marketplace_settings add column inquiry_hourly_limit integer not null default 10 check (inquiry_hourly_limit between 1 and 1000);

create function public.set_package_availability(
  p_revision uuid,p_availability uuid,p_kind text,p_starts date,p_ends date,
  p_status text,p_remaining integer,p_source text,p_request uuid
) returns uuid language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; r public.package_revisions;
begin
  select * into strict r from public.package_revisions where id=p_revision;
  perform private.require_agency(r.agency_id);
  v_id:=private.begin_operation(p_request,'set_availability',jsonb_build_array(p_revision,p_availability,p_kind,p_starts,p_ends,p_status,p_remaining,p_source));
  if v_id is not null then return v_id; end if;
  perform 1 from public.agencies where id=r.agency_id for update;
  if r.status not in ('draft','approved') then raise exception 'Revision cannot accept availability changes' using errcode='23514'; end if;
  if p_kind='fixed_departure' and p_ends-p_starts+1<>r.duration_days then raise exception 'Departure duration mismatch' using errcode='23514'; end if;
  if p_status='open' and p_remaining is null then raise exception 'Open availability requires known capacity' using errcode='23514'; end if;
  if p_availability is null then
    insert into public.package_availability(revision_id,agency_id,kind,starts_on,ends_on,status,remaining_travelers,confirmed_at,confirmed_by,source_note)
      values(r.id,r.agency_id,p_kind,p_starts,p_ends,p_status,p_remaining,statement_timestamp(),auth.uid(),p_source) returning id into v_id;
  else
    update public.package_availability set kind=p_kind,starts_on=p_starts,ends_on=p_ends,status=p_status,
      remaining_travelers=p_remaining,confirmed_at=statement_timestamp(),confirmed_by=auth.uid(),source_note=p_source,updated_at=statement_timestamp()
      where id=p_availability and revision_id=r.id and agency_id=r.agency_id returning id into v_id;
    if not found then raise exception 'Owned availability record required' using errcode='42501'; end if;
  end if;
  perform private.write_audit('availability_confirmed','package_availability',v_id,r.agency_id);
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function public.request_subscription_change(p_agency uuid,p_version uuid,p_request uuid)
returns uuid language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid;
begin
  perform private.require_agency(p_agency);
  v_id:=private.begin_operation(p_request,'subscription_request',jsonb_build_array(p_agency,p_version));
  if v_id is not null then return v_id; end if;
  insert into public.subscription_change_requests(agency_id,requested_plan_version_id,requested_by,request_id)
    values(p_agency,p_version,auth.uid(),p_request) returning id into v_id;
  perform private.write_audit('subscription_requested','subscription_change_requests',v_id,p_agency);
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function public.admin_create_placement(
  p_package uuid,p_surface text,p_destination uuid,p_starts timestamptz,p_ends timestamptz,p_request uuid
) returns uuid language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; v_agency uuid; ent public.subscription_plan_versions; v_count bigint;
begin
  perform private.require_admin();
  v_id:=private.begin_operation(p_request,'create_placement',jsonb_build_array(p_package,p_surface,p_destination,p_starts,p_ends));
  if v_id is not null then return v_id; end if;
  select agency_id into strict v_agency from public.packages where id=p_package;
  perform 1 from public.agencies where id=v_agency for update;
  if not private.package_visible(p_package) then raise exception 'Eligible package required' using errcode='23514'; end if;
  select * into strict ent from private.effective_plan(v_agency);
  if not ent.can_sponsor then raise exception 'Promotional entitlement required' using errcode='23514'; end if;
  if p_destination is not null and not exists (
    select 1 from public.packages p join public.package_destinations d on d.revision_id=p.published_revision_id where p.id=p_package and d.destination_id=p_destination
  ) then raise exception 'Placement destination mismatch' using errcode='23514'; end if;
  -- Conservative overlap accounting: never oversubscribe an agency's allowance.
  select count(*) into v_count from public.featured_placements
    where agency_id=v_agency and status='active' and tstzrange(starts_at,ends_at,'[)') && tstzrange(p_starts,p_ends,'[)');
  if v_count>=ent.max_active_placements then raise exception 'Promotional allowance reached' using errcode='23514'; end if;
  insert into public.featured_placements(package_id,agency_id,surface,destination_id,starts_at,ends_at,status,approved_by,request_id)
    values(p_package,v_agency,p_surface,p_destination,p_starts,p_ends,'active',auth.uid(),p_request) returning id into v_id;
  perform private.write_audit('placement_created','featured_placements',v_id,v_agency);
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function public.catalog_destinations(p_limit integer default 20) returns jsonb
language sql stable security definer set search_path = ''
as $fn$
  select coalesce(jsonb_agg(x.doc order by x.name,x.id),'[]'::jsonb) from (
    select d.id,d.name,jsonb_build_object('id',d.id,'name',d.name,'slug',d.slug,
      'description',d.short_description,'min_days',d.min_days,'max_days',d.max_days,
      'last_verified_at',d.last_verified_at) doc
    from public.destinations d where d.published order by d.name,d.id limit greatest(1,least(coalesce(p_limit,20),100))
  ) x;
$fn$;
create function public.catalog_packages(p_destination uuid default null,p_limit integer default 20) returns jsonb
language sql volatile security definer set search_path = ''
as $fn$
  select coalesce(jsonb_agg(x.doc order by x.title,x.id),'[]'::jsonb) from (
    select p.id,r.title,jsonb_build_object('id',p.id,'slug',p.slug,'revision_id',r.id,'title',r.title,
      'duration_days',r.duration_days,'nights',r.nights,'agency_id',a.id,'agency_name',a.name,'agency_slug',a.slug,
      'min_travelers',r.min_travelers,'max_travelers',r.max_travelers,'last_reconfirmed_at',p.last_reconfirmed_at,
      'price_status','Select travelers and dates for a quote','result_source','organic') doc
    from public.packages p join public.package_revisions r on r.id=p.published_revision_id join public.agencies a on a.id=p.agency_id
    where private.package_visible(p.id) and (p_destination is null or exists (
      select 1 from public.package_destinations d where d.revision_id=r.id and d.destination_id=p_destination
    )) order by r.title,p.id limit greatest(1,least(coalesce(p_limit,20),100))
  ) x;
$fn$;
create function public.package_detail(p_package uuid) returns jsonb
language plpgsql volatile security definer set search_path = ''
as $fn$
declare v_doc jsonb;
begin
  if not private.package_visible(p_package) then return null; end if;
  select jsonb_build_object('id',p.id,'slug',p.slug,'revision_id',r.id,'title',r.title,'description',r.description,
    'duration_days',r.duration_days,'nights',r.nights,'inclusions',r.inclusions,'exclusions',r.exclusions,
    'agency',jsonb_build_object('name',a.name,'slug',a.slug,'website',a.website_url,'email',a.public_email,'phone',a.public_phone,'whatsapp',a.whatsapp),
    'booking_url',coalesce(r.booking_url,a.website_url),
    'media',coalesce((select jsonb_agg(jsonb_build_object('url',m.url,'alt',m.alt_text,'credit',m.credit,'license',m.license) order by m.sort_order)
      from public.package_media m where m.revision_id=r.id),'[]'::jsonb),
    'itinerary',coalesce((select jsonb_agg(jsonb_build_object('day',d.day_number,'title',d.title,'notes',d.notes) order by d.day_number)
      from public.package_itinerary_days d where d.revision_id=r.id),'[]'::jsonb),
    'destinations',coalesce((select jsonb_agg(jsonb_build_object('id',d.id,'name',d.name,'slug',d.slug) order by pd.stop_order)
      from public.package_destinations pd join public.destinations d on d.id=pd.destination_id where pd.revision_id=r.id),'[]'::jsonb),
    'last_reconfirmed_at',p.last_reconfirmed_at,'availability_status','Select dates to check agency-reported availability')
    into v_doc from public.packages p join public.package_revisions r on r.id=p.published_revision_id join public.agencies a on a.id=p.agency_id where p.id=p_package;
  return v_doc;
end;
$fn$;
create function public.sponsored_packages(p_surface text,p_destination uuid default null,p_limit integer default 5) returns jsonb
language sql volatile security definer set search_path = ''
as $fn$
  select coalesce(jsonb_agg(x.doc order by x.starts_at,x.id),'[]'::jsonb) from (
    select f.id,f.starts_at,jsonb_build_object('placement_id',f.id,'label','Sponsored','result_source','sponsored','package',public.package_detail(f.package_id)) doc
    from public.featured_placements f join lateral private.effective_plan(f.agency_id) ent on true
    where f.status='active' and f.surface=p_surface and f.destination_id is not distinct from p_destination
      and f.starts_at<=statement_timestamp() and statement_timestamp()<f.ends_at
      and private.package_visible(f.package_id) and ent.can_sponsor
      and (select count(*) from public.featured_placements q where q.agency_id=f.agency_id and q.status='active' and q.starts_at<=statement_timestamp() and statement_timestamp()<q.ends_at)<=ent.max_active_placements
    order by f.starts_at,f.id limit greatest(1,least(coalesce(p_limit,5),20))
  ) x;
$fn$;

create function public.submit_inquiry(
  p_package uuid,p_travelers integer,p_start date,p_name text,p_email text,p_phone text,p_message text,
  p_consent_version text,p_abuse_key_hash text,p_request uuid,p_traveler uuid default null
) returns uuid language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; v_fingerprint text; v_existing public.inquiries; v_quote jsonb; v_agency uuid;
  v_revision uuid; v_attempts integer; v_limit integer; v_window timestamptz;
begin
  -- EXECUTE is restricted to service_role. A future trusted server verifies the user,
  -- Zod/contact/consent input, origin/CSRF and a secret-HMAC abuse key before calling.
  if p_request is null or p_abuse_key_hash is null or p_abuse_key_hash !~ '^[a-f0-9]{64}$' then
    raise exception 'Valid inquiry request required' using errcode='22023';
  end if;
  if p_email is not null and p_email !~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$' then raise exception 'Invalid email' using errcode='22023'; end if;
  v_fingerprint:=encode(sha256(convert_to(jsonb_build_array(p_package,p_travelers,p_start,p_name,p_email,p_phone,p_message,p_consent_version,p_traveler,p_abuse_key_hash)::text,'UTF8')),'hex');
  -- Serialize retries globally without storing messages in operational audit rows.
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_request::text,0));
  select * into v_existing from public.inquiries where request_id=p_request;
  if found then
    if v_existing.request_fingerprint<>v_fingerprint then raise exception 'Idempotency key conflict' using errcode='22023'; end if;
    return v_existing.id;
  end if;
  if not (select inquiries_enabled from public.marketplace_settings) or not exists(
    select 1 from public.retention_policies where data_category='inquiries' and retain_days is not null and char_length(btrim(policy_note))>0
  ) then raise exception 'Inquiry collection is not configured for launch' using errcode='23514'; end if;
  v_window:=date_trunc('hour',statement_timestamp());
  select inquiry_hourly_limit into strict v_limit from public.marketplace_settings;
  insert into public.inquiry_rate_limits(abuse_key_hash,window_start,attempts) values(p_abuse_key_hash,v_window,1)
    on conflict(abuse_key_hash,window_start) do update set attempts=public.inquiry_rate_limits.attempts+1 returning attempts into v_attempts;
  if v_attempts>v_limit then raise exception 'Inquiry limit reached' using errcode='P0001'; end if;
  select agency_id into strict v_agency from public.packages where id=p_package;
  -- Serialize quote capture against publication, suspension and subscription changes.
  perform 1 from public.agencies where id=v_agency for update;
  v_quote:=private.quote_package(p_package,p_travelers,p_start);
  select published_revision_id into strict v_revision from public.packages where id=p_package;
  insert into public.inquiries(package_id,revision_id,agency_id,user_id,contact_name,contact_email,contact_phone,
    message,consent_version,travelers,starts_on,quote_snapshot,request_id,request_fingerprint)
    values(p_package,v_revision,v_agency,p_traveler,p_name,p_email,p_phone,p_message,p_consent_version,p_travelers,p_start,v_quote,p_request,v_fingerprint)
    returning id into v_id;
  perform private.write_audit('inquiry_created','inquiries',v_id,v_agency);
  insert into public.marketplace_events(agency_id,package_id,event_type,source,request_id)
    values(v_agency,p_package,'inquiry','organic',p_request);
  return v_id;
end;
$fn$;

create function public.update_inquiry_status(p_inquiry uuid,p_status text,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; v_agency uuid;
begin
  select agency_id into strict v_agency from public.inquiries where id=p_inquiry;
  perform private.require_agency(v_agency);
  v_id:=private.begin_operation(p_request,'inquiry_status',jsonb_build_array(p_inquiry,p_status));
  if v_id is not null then return v_id; end if;
  update public.inquiries set status=p_status where id=p_inquiry;
  perform private.write_audit('inquiry_status_changed','inquiries',p_inquiry,v_agency);
  return private.finish_operation(p_request,p_inquiry);
end;
$fn$;

create function public.save_package_comparison(p_trip uuid,p_package uuid,p_request uuid)
returns uuid language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; t public.trips; v_quote jsonb; p public.packages; r public.package_revisions;
begin
  if auth.uid() is null then raise exception 'Authentication required' using errcode='42501'; end if;
  v_id:=private.begin_operation(p_request,'save_comparison',jsonb_build_array(p_trip,p_package));
  if v_id is not null then return v_id; end if;
  select * into strict t from public.trips where id=p_trip and user_id=auth.uid() for share;
  select * into strict p from public.packages where id=p_package;
  perform 1 from public.agencies where id=p.agency_id for share;
  v_quote:=private.quote_package(p.id,t.travelers,t.start_date);
  select * into strict r from public.package_revisions where id=(v_quote->>'revision_id')::uuid;
  v_quote:=v_quote || jsonb_build_object('mismatches',to_jsonb(array_remove(array[
    case when t.days<>r.duration_days then 'duration' end,
    case when t.origin_id is not null and not exists(select 1 from public.package_origins where revision_id=r.id and location_id=t.origin_id) then 'origin' end,
    case when t.destination_id is not null and not exists(select 1 from public.package_destinations where revision_id=r.id and destination_id=t.destination_id) then 'destination' end,
    case when not coalesce((v_quote->>'whole_trip_budget_known')::boolean,false) then 'whole_trip_cost_incomplete' end,
    case when t.budget_total_minor is not null and (v_quote->>'total_minor')::bigint>t.budget_total_minor then 'budget' end,
    case when v_quote->>'reason'='group_size_mismatch' then 'group_size' end,
    case when t.start_date is not null and v_quote->>'availability_status' is distinct from 'agency_confirmed' then 'dates_require_confirmation' end
  ]::text[],null)));
  insert into public.trip_package_comparisons(trip_id,user_id,package_id,revision_id,agency_id,input_snapshot,quote_snapshot,request_id)
    values(t.id,auth.uid(),p.id,(v_quote->>'revision_id')::uuid,p.agency_id,
      jsonb_build_object('travelers',t.travelers,'starts_on',t.start_date,'days',t.days,'origin_id',t.origin_id,'budget_total_minor',t.budget_total_minor),
      v_quote,p_request) returning id into v_id;
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function public.create_trip_share(p_trip uuid,p_token_hash text,p_expires timestamptz,p_request uuid)
returns uuid language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required' using errcode='42501'; end if;
  v_id:=private.begin_operation(p_request,'create_trip_share',jsonb_build_array(p_trip,p_token_hash,p_expires));
  if v_id is not null then return v_id; end if;
  perform 1 from public.trips where id=p_trip and user_id=auth.uid() for update;
  if not found then raise exception 'Owned trip required' using errcode='42501'; end if;
  if p_expires is not null and p_expires<=statement_timestamp() then raise exception 'Share expiry must be in the future' using errcode='22023'; end if;
  update public.trips set visibility='unlisted' where id=p_trip;
  insert into public.trip_shares(trip_id,user_id,token_hash,expires_at) values(p_trip,auth.uid(),p_token_hash,p_expires) returning id into v_id;
  return private.finish_operation(p_request,v_id);
end;
$fn$;
create function public.revoke_trip_share(p_share uuid) returns void
language plpgsql security definer set search_path = ''
as $fn$
begin
  if auth.uid() is null then raise exception 'Authentication required' using errcode='42501'; end if;
  update public.trip_shares set revoked_at=statement_timestamp() where id=p_share and user_id=auth.uid();
  if not found then raise exception 'Owned share required' using errcode='42501'; end if;
end;
$fn$;
create function public.shared_trip(p_token text) returns jsonb
language sql stable security definer set search_path = ''
as $fn$
  select jsonb_build_object('title',t.title,'days',t.days,'travelers',t.travelers,
    'itinerary',coalesce((select jsonb_agg(jsonb_build_object('day',d.day_number,'title',d.title) order by d.day_number) from public.trip_days d where d.trip_id=t.id),'[]'::jsonb))
  from public.trip_shares s join public.trips t on t.id=s.trip_id
  where char_length(p_token) between 43 and 128 and p_token ~ '^[A-Za-z0-9_-]+$'
    and s.token_hash=encode(sha256(convert_to(p_token,'UTF8')),'hex') and s.revoked_at is null
    and (s.expires_at is null or statement_timestamp()<s.expires_at) and t.visibility='unlisted';
$fn$;

revoke all on function public.set_package_availability(uuid,uuid,text,date,date,text,integer,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.set_package_availability(uuid,uuid,text,date,date,text,integer,text,uuid) to authenticated;
revoke all on function public.request_subscription_change(uuid,uuid,uuid) from public,anon,authenticated,service_role;
grant execute on function public.request_subscription_change(uuid,uuid,uuid) to authenticated;
revoke all on function public.admin_create_placement(uuid,text,uuid,timestamptz,timestamptz,uuid) from public,anon,authenticated,service_role;
grant execute on function public.admin_create_placement(uuid,text,uuid,timestamptz,timestamptz,uuid) to authenticated;
revoke all on function public.catalog_destinations(integer) from public,anon,authenticated,service_role;
grant execute on function public.catalog_destinations(integer) to anon,authenticated;
revoke all on function public.catalog_packages(uuid,integer) from public,anon,authenticated,service_role;
grant execute on function public.catalog_packages(uuid,integer) to anon,authenticated;
revoke all on function public.package_detail(uuid) from public,anon,authenticated,service_role;
grant execute on function public.package_detail(uuid) to anon,authenticated;
revoke all on function public.sponsored_packages(text,uuid,integer) from public,anon,authenticated,service_role;
grant execute on function public.sponsored_packages(text,uuid,integer) to anon,authenticated;
revoke all on function public.submit_inquiry(uuid,integer,date,text,text,text,text,text,text,uuid,uuid) from public,anon,authenticated,service_role;
grant execute on function public.submit_inquiry(uuid,integer,date,text,text,text,text,text,text,uuid,uuid) to service_role;
revoke all on function public.update_inquiry_status(uuid,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.update_inquiry_status(uuid,text,uuid) to authenticated;
revoke all on function public.save_package_comparison(uuid,uuid,uuid) from public,anon,authenticated,service_role;
grant execute on function public.save_package_comparison(uuid,uuid,uuid) to authenticated;
revoke all on function public.create_trip_share(uuid,text,timestamptz,uuid) from public,anon,authenticated,service_role;
grant execute on function public.create_trip_share(uuid,text,timestamptz,uuid) to authenticated;
revoke all on function public.revoke_trip_share(uuid) from public,anon,authenticated,service_role;
grant execute on function public.revoke_trip_share(uuid) to authenticated;
revoke all on function public.shared_trip(text) from public,anon,authenticated,service_role;
grant execute on function public.shared_trip(text) to anon,authenticated;
commit;
