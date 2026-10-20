-- REVIEW DRAFT: do not execute without explicit database approval.
-- Supabase PostgreSQL 17+, run as the trusted migration owner.
begin;

create function private.effective_plan(p_agency uuid)
returns setof public.subscription_plan_versions
language sql volatile security definer set search_path = ''
as $fn$
  select v.* from public.agency_subscriptions s
  join public.subscription_plan_versions v on v.id=s.plan_version_id
  join public.subscription_plans p on p.id=v.plan_id
  where s.agency_id=p_agency and s.status='active'
    and s.starts_at<=statement_timestamp() and statement_timestamp()<s.ends_at
    and p.is_active and v.can_publish and v.price_minor is not null;
$fn$;

create function private.package_visible(p_package uuid) returns boolean
language sql volatile security definer set search_path = ''
as $fn$
  select exists (
    select 1 from public.packages p
    join public.agencies a on a.id=p.agency_id
    join public.package_revisions r on r.id=p.published_revision_id and r.package_id=p.id and r.agency_id=p.agency_id
    cross join public.marketplace_settings cfg
    join lateral private.effective_plan(p.agency_id) ent on true
    where p.id=p_package and p.state='published' and r.status='approved'
      and a.approval_status='approved' and a.operational_status='active'
      and p.reconfirmed_revision_id=r.id
      and p.last_reconfirmed_at<=statement_timestamp()
      and p.last_reconfirmed_at>statement_timestamp()-pg_catalog.make_interval(days=>cfg.package_reconfirmation_days)
      and (ent.max_published_packages is null or
        (select count(*) from public.packages q where q.agency_id=p.agency_id and q.state='published')<=ent.max_published_packages)
      and exists (select 1 from public.package_destinations d where d.revision_id=r.id and d.is_primary)
      and not exists (select 1 from public.package_destinations d join public.destinations x on x.id=d.destination_id where d.revision_id=r.id and not x.published)
      and exists (select 1 from public.package_price_rules pr where pr.revision_id=r.id and pr.sales_from<=statement_timestamp() and statement_timestamp()<pr.sales_until
        and (pr.travel_until is null or pr.travel_until>=(statement_timestamp() at time zone 'Asia/Kathmandu')::date))
  );
$fn$;

create function private.calculate_group_price(
  p_base bigint,p_basis text,p_travelers integer,p_days integer,p_nights integer,p_components jsonb
) returns jsonb
language plpgsql immutable set search_path = ''
as $fn$
declare v_total numeric; v_component jsonb; v_amount numeric; v_quantity numeric;
begin
  if p_base is null or p_base<0 or p_basis is null or p_basis not in ('per_person','per_group')
    or p_travelers is null or p_travelers not between 1 and 10000
    or p_days is null or p_days not between 1 and 365
    or p_nights is null or p_nights<0 or p_nights>=p_days
    or p_components is null or jsonb_typeof(p_components)<>'array' then
    raise exception 'Invalid quote input' using errcode='22023';
  end if;
  v_total:=p_base::numeric * case when p_basis='per_person' then p_travelers else 1 end;
  for v_component in select value from jsonb_array_elements(p_components) loop
    -- Unsupported discounts must fail explicitly, not silently disappear.
    if jsonb_typeof(v_component) is distinct from 'object'
      or v_component->>'classification' is null
      or v_component->>'classification' not in ('included','mandatory','optional') then
      raise exception 'Invalid fee classification' using errcode='22023';
    end if;
    if v_component->>'classification'='mandatory' then
      if v_component->>'amount_minor' is null then
        return jsonb_build_object('complete',false,'total_minor',null,'reason','unpriced_required_charge');
      end if;
      if v_component->>'unit' not in ('person','group') or v_component->>'frequency' not in ('trip','day','night')
        or v_component->>'unit' is null or v_component->>'frequency' is null then
        raise exception 'Invalid fee units' using errcode='22023';
      end if;
      v_amount:=(v_component->>'amount_minor')::numeric;
      if v_amount<0 or v_amount<>trunc(v_amount) then raise exception 'Invalid fee amount' using errcode='22023'; end if;
      v_quantity:=case when v_component->>'unit'='person' then p_travelers else 1 end *
        case v_component->>'frequency' when 'day' then p_days when 'night' then p_nights else 1 end;
      v_total:=v_total+v_amount*v_quantity;
    end if;
  end loop;
  if v_total>9000000000000000 then raise exception 'Quote exceeds supported amount' using errcode='22003'; end if;
  return jsonb_build_object('complete',true,'total_minor',v_total::bigint,'currency','NPR','travelers',p_travelers);
end;
$fn$;

create function private.quote_package(p_package uuid,p_travelers integer,p_start date default null)
returns jsonb language plpgsql stable security definer set search_path = ''
as $fn$
declare v_revision public.package_revisions; v_rule public.package_price_rules;
  v_quote jsonb; v_end date; v_components jsonb; v_available boolean:=false;
begin
  if p_travelers is null or p_travelers not between 1 and 10000 then
    raise exception 'Invalid traveler count' using errcode='22023';
  end if;
  if p_start is not null and (not isfinite(p_start) or p_start<(statement_timestamp() at time zone 'Asia/Kathmandu')::date) then
    raise exception 'A valid future travel date is required' using errcode='22023';
  end if;
  if not private.package_visible(p_package) then
    raise exception 'Package is not publicly eligible' using errcode='22023';
  end if;
  select r.* into strict v_revision from public.packages p join public.package_revisions r on r.id=p.published_revision_id where p.id=p_package;
  if p_travelers not between v_revision.min_travelers and v_revision.max_travelers then
    return jsonb_build_object('package_id',p_package,'revision_id',v_revision.id,'complete',false,'total_minor',null,'whole_trip_budget_known',false,'reason','group_size_mismatch');
  end if;
  if p_start is not null then v_end:=p_start+v_revision.duration_days-1; end if;
  select pr.* into v_rule from public.package_price_rules pr
    where pr.revision_id=v_revision.id and p_travelers between pr.min_travelers and pr.max_travelers
      and pr.sales_from<=statement_timestamp() and statement_timestamp()<pr.sales_until
      and ((p_start is null and pr.travel_from is null and pr.travel_until is null)
        or (p_start is not null and pr.travel_scope @> daterange(p_start,v_end,'[]')));
  if not found then return jsonb_build_object('package_id',p_package,'revision_id',v_revision.id,'complete',false,'total_minor',null,'whole_trip_budget_known',false,'reason','no_applicable_price'); end if;
  select coalesce(jsonb_agg(jsonb_build_object('label',c.label,'classification',c.classification,'amount_minor',c.amount_minor,'unit',c.unit,'frequency',c.frequency) order by c.id),'[]'::jsonb)
    into v_components from public.package_price_components c where c.price_rule_id=v_rule.id;
  v_quote:=private.calculate_group_price(v_rule.base_minor,v_rule.basis,p_travelers,v_revision.duration_days,v_revision.nights,v_components);
  if p_start is not null then
    select exists (
      select 1 from public.package_availability av cross join public.marketplace_settings cfg
      where av.revision_id=v_revision.id and av.status='open' and av.remaining_travelers>=p_travelers
        and av.confirmed_at<=statement_timestamp()
        and av.confirmed_at>statement_timestamp()-pg_catalog.make_interval(days=>cfg.package_reconfirmation_days)
        and ((av.kind='fixed_departure' and av.starts_on=p_start and av.ends_on=v_end)
          or (av.kind='operating_window' and av.travel_scope @> daterange(p_start,v_end,'[]')))
    ) into v_available;
  end if;
  return v_quote || jsonb_build_object(
    'package_id',p_package,'revision_id',v_revision.id,'price_rule_id',v_rule.id,
    'basis',v_rule.basis,'base_minor',v_rule.base_minor,'components',v_components,
    'starts_on',p_start,'ends_on',v_end,'quoted_at',statement_timestamp(),
    'whole_trip_budget_known',not v_revision.necessary_exclusions_unpriced and (v_quote->>'complete')::boolean,
    'inclusions',v_revision.inclusions,'exclusions',v_revision.exclusions,
    'availability_status',case when p_start is null then 'not_checked' when v_available then 'agency_confirmed' else 'requires_confirmation' end
  );
end;
$fn$;

create function public.quote_package(p_package uuid,p_travelers integer,p_start date default null)
returns jsonb language sql stable security definer set search_path = ''
as $fn$ select private.quote_package(p_package,p_travelers,p_start); $fn$;
revoke all on function private.effective_plan(uuid) from public,anon,authenticated,service_role;
revoke all on function private.package_visible(uuid) from public,anon,authenticated,service_role;
revoke all on function private.calculate_group_price(bigint,text,integer,integer,integer,jsonb) from public,anon,authenticated,service_role;
revoke all on function private.quote_package(uuid,integer,date) from public,anon,authenticated,service_role;
revoke all on function public.quote_package(uuid,integer,date) from public,anon,authenticated,service_role;
grant execute on function public.quote_package(uuid,integer,date) to anon,authenticated;
commit;
