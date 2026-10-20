-- REVIEW DRAFT: do not execute without explicit database approval.
-- Supabase PostgreSQL 17+, run as the trusted migration owner.
begin;

-- Final integrity checks; no destructive data operations are executed by preparation.
alter table public.agency_verifications add constraint verification_evidence_required check (
  coalesce(char_length(btrim(business_registration_reference)),0)>0 or evidence_storage_path is not null
);
alter table public.trip_package_comparisons add constraint comparison_snapshot_version check (
  quote_snapshot ? 'revision_id' and quote_snapshot->>'revision_id'=revision_id::text
);

create function public.reopen_package_revision(p_revision uuid,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; r public.package_revisions;
begin
  select * into strict r from public.package_revisions where id=p_revision;
  perform private.require_agency(r.agency_id);
  v_id:=private.begin_operation(p_request,'reopen_revision',jsonb_build_array(p_revision));
  if v_id is not null then return v_id; end if;
  select * into strict r from public.package_revisions where id=p_revision for update;
  if r.status<>'rejected' then raise exception 'Only rejected revisions can be reopened' using errcode='23514'; end if;
  update public.package_revisions set status='draft',reviewed_by=null,reviewed_at=null where id=r.id;
  perform private.write_audit('revision_reopened','package_revisions',r.id,r.agency_id);
  return private.finish_operation(p_request,r.id);
end;
$fn$;

create function public.admin_set_role(p_user uuid,p_role text,p_enabled boolean,p_reason text,p_request uuid)
returns uuid language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid;
begin
  perform private.require_admin();
  v_id:=private.begin_operation(p_request,'set_role',jsonb_build_array(p_user,p_role,p_enabled,p_reason));
  if v_id is not null then return v_id; end if;
  if p_role is null or p_role not in ('traveler','agency','admin') or p_enabled is null or coalesce(char_length(btrim(p_reason)),0)=0 then
    raise exception 'Valid role decision and reason required' using errcode='22023';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('ghumne.role_administration',0));
  -- Recheck after waiting for another admin's grant/revocation.
  perform private.require_admin();
  if p_enabled then
    insert into public.user_roles(user_id,role,granted_by) values(p_user,p_role,auth.uid()) on conflict do nothing;
  else
    if p_role='admin' and not exists(select 1 from public.user_roles where role='admin' and user_id<>p_user) then
      raise exception 'Cannot remove the last administrator' using errcode='23514';
    end if;
    if p_role='agency' and exists(select 1 from public.agency_memberships where user_id=p_user and status='active') then
      raise exception 'Resolve active agency ownership first' using errcode='23514';
    end if;
    delete from public.user_roles where user_id=p_user and role=p_role;
  end if;
  perform private.write_audit('role_changed','profiles',p_user,null,p_reason);
  return private.finish_operation(p_request,p_user);
end;
$fn$;

create function public.admin_set_plan_active(p_plan uuid,p_active boolean,p_reason text,p_request uuid)
returns uuid language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid;
begin
  perform private.require_admin();
  v_id:=private.begin_operation(p_request,'set_plan_active',jsonb_build_array(p_plan,p_active,p_reason));
  if v_id is not null then return v_id; end if;
  if p_active is null or coalesce(char_length(btrim(p_reason)),0)=0 then raise exception 'State and reason required' using errcode='22023'; end if;
  update public.subscription_plans set is_active=p_active where id=p_plan;
  if not found then raise exception 'Plan not found' using errcode='22023'; end if;
  perform private.write_audit('plan_state_changed','subscription_plans',p_plan,null,p_reason);
  return private.finish_operation(p_request,p_plan);
end;
$fn$;

create function public.admin_pause_placement(p_placement uuid,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; v_agency uuid;
begin
  perform private.require_admin();
  v_id:=private.begin_operation(p_request,'pause_placement',jsonb_build_array(p_placement));
  if v_id is not null then return v_id; end if;
  select agency_id into strict v_agency from public.featured_placements where id=p_placement;
  perform 1 from public.agencies where id=v_agency for update;
  update public.featured_placements set status='paused' where id=p_placement;
  perform private.write_audit('placement_paused','featured_placements',p_placement,v_agency);
  return private.finish_operation(p_request,p_placement);
end;
$fn$;

create function private.guard_trip_day() returns trigger
language plpgsql security definer set search_path = ''
as $fn$
declare v_days integer;
begin
  select days into strict v_days from public.trips where id=new.trip_id and user_id=new.user_id for update;
  if new.day_number>v_days then raise exception 'Day exceeds trip duration' using errcode='23514'; end if;
  return new;
end;
$fn$;
create trigger trip_day_bounds before insert or update on public.trip_days for each row execute function private.guard_trip_day();
create function private.guard_trip_duration() returns trigger
language plpgsql security definer set search_path = ''
as $fn$
begin
  if exists(select 1 from public.trip_days where trip_id=old.id and day_number>new.days) then
    raise exception 'Reconcile itinerary before shortening trip' using errcode='23514';
  end if;
  return new;
end;
$fn$;
create trigger trip_duration_bounds before update of days on public.trips for each row execute function private.guard_trip_duration();

create function private.audit_safe_change() returns trigger
language plpgsql security definer set search_path = ''
as $fn$
declare v_doc jsonb;
begin
  if tg_op='DELETE' then v_doc:=to_jsonb(old); else v_doc:=to_jsonb(new); end if;
  -- IDs/actions only: never copy raw verification, contact, notes or price payloads.
  perform private.write_audit(lower(tg_op),tg_table_name,(v_doc->>'id')::uuid,(v_doc->>'agency_id')::uuid);
  if tg_op='DELETE' then return old; else return new; end if;
end;
$fn$;
create trigger package_price_rules_audit after insert or update or delete on public.package_price_rules for each row execute function private.audit_safe_change();
create trigger package_price_components_audit after insert or update or delete on public.package_price_components for each row execute function private.audit_safe_change();
create trigger marketplace_settings_audit after insert or update or delete on public.marketplace_settings for each row execute function private.audit_safe_change();
create trigger retention_policies_audit after insert or update or delete on public.retention_policies for each row execute function private.audit_safe_change();
create trigger locations_audit after insert or update or delete on public.locations for each row execute function private.audit_safe_change();
create trigger destinations_audit after insert or update or delete on public.destinations for each row execute function private.audit_safe_change();
create trigger destination_media_audit after insert or update or delete on public.destination_media for each row execute function private.audit_safe_change();
create trigger interests_audit after insert or update or delete on public.interests for each row execute function private.audit_safe_change();
create trigger destination_interests_audit after insert or update or delete on public.destination_interests for each row execute function private.audit_safe_change();
create trigger destination_seasons_audit after insert or update or delete on public.destination_seasons for each row execute function private.audit_safe_change();
create trigger attractions_audit after insert or update or delete on public.attractions for each row execute function private.audit_safe_change();
create trigger activities_audit after insert or update or delete on public.activities for each row execute function private.audit_safe_change();
create trigger transport_routes_audit after insert or update or delete on public.transport_routes for each row execute function private.audit_safe_change();
create trigger destination_costs_audit after insert or update or delete on public.destination_costs for each row execute function private.audit_safe_change();
create trigger settings_touch before update on public.marketplace_settings for each row execute function private.touch_updated_at();
create trigger retention_touch before update on public.retention_policies for each row execute function private.touch_updated_at();

revoke all on function public.reopen_package_revision(uuid,uuid) from public,anon,authenticated,service_role;
grant execute on function public.reopen_package_revision(uuid,uuid) to authenticated;
revoke all on function public.admin_set_role(uuid,text,boolean,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.admin_set_role(uuid,text,boolean,text,uuid) to authenticated;
revoke all on function public.admin_set_plan_active(uuid,boolean,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.admin_set_plan_active(uuid,boolean,text,uuid) to authenticated;
revoke all on function public.admin_pause_placement(uuid,uuid) from public,anon,authenticated,service_role;
grant execute on function public.admin_pause_placement(uuid,uuid) to authenticated;
revoke all on function private.guard_trip_day() from public,anon,authenticated,service_role;
revoke all on function private.guard_trip_duration() from public,anon,authenticated,service_role;
revoke all on function private.audit_safe_change() from public,anon,authenticated,service_role;
commit;
