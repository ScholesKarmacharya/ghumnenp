-- REVIEW DRAFT: do not execute without explicit database approval.
-- Supabase PostgreSQL 17+, run as the trusted migration owner.
begin;

create table private.operation_requests (
  request_id uuid primary key,
  actor_id uuid not null references public.profiles(id) on delete restrict,
  action text not null, fingerprint text not null, result_id uuid,
  created_at timestamptz not null default now()
);
alter table private.operation_requests enable row level security;
revoke all on table private.operation_requests from public,anon,authenticated,service_role;
create function private.begin_operation(p_request uuid,p_action text,p_input jsonb) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_row private.operation_requests; v_hash text;
begin
  if auth.uid() is null or p_request is null then raise exception 'Authenticated request ID required' using errcode='42501'; end if;
  v_hash:=encode(sha256(convert_to(p_input::text,'UTF8')),'hex');
  insert into private.operation_requests(request_id,actor_id,action,fingerprint)
  values (p_request,auth.uid(),p_action,v_hash) on conflict do nothing;
  select * into strict v_row from private.operation_requests where request_id=p_request for update;
  if v_row.actor_id<>auth.uid() or v_row.action<>p_action or v_row.fingerprint<>v_hash then
    raise exception 'Idempotency key conflict' using errcode='22023';
  end if;
  return v_row.result_id;
end;
$fn$;
create function private.finish_operation(p_request uuid,p_result uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
begin
  update private.operation_requests set result_id=p_result where request_id=p_request and actor_id=auth.uid();
  return p_result;
end;
$fn$;

create function public.ensure_profile() returns uuid
language plpgsql security definer set search_path = ''
as $fn$
begin
  if auth.uid() is null then raise exception 'Authentication required' using errcode='42501'; end if;
  insert into public.profiles(id) values (auth.uid()) on conflict do nothing;
  insert into public.user_roles(user_id,role) values (auth.uid(),'traveler') on conflict do nothing;
  return auth.uid();
end;
$fn$;

create function public.register_agency(p_name text,p_slug text,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid;
begin
  perform public.ensure_profile();
  v_id:=private.begin_operation(p_request,'register_agency',jsonb_build_array(p_name,p_slug));
  if v_id is not null then return v_id; end if;
  insert into public.agencies(name,slug) values(p_name,p_slug) returning id into v_id;
  insert into public.user_roles(user_id,role) values(auth.uid(),'agency') on conflict do nothing;
  insert into public.agency_memberships(agency_id,user_id) values(v_id,auth.uid());
  perform private.write_audit('agency_registered','agencies',v_id,v_id);
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function public.submit_agency_verification(p_agency uuid,p_reference text,p_storage_path text,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid;
begin
  perform private.require_agency(p_agency);
  v_id:=private.begin_operation(p_request,'submit_verification',jsonb_build_array(p_agency,p_reference,p_storage_path));
  if v_id is not null then return v_id; end if;
  -- Object access requires a private, tenant-scoped Storage policy before uploads are enabled.
  if p_storage_path is not null and p_storage_path not like p_agency::text || '/%' then
    raise exception 'Evidence must use the agency private storage prefix' using errcode='22023';
  end if;
  insert into public.agency_verifications(agency_id,submitted_by,business_registration_reference,evidence_storage_path)
    values(p_agency,auth.uid(),p_reference,p_storage_path) returning id into v_id;
  perform private.write_audit('verification_submitted','agency_verifications',v_id,p_agency);
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function public.admin_review_agency(p_verification uuid,p_approved boolean,p_reason text,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; v_agency uuid; v_status text;
begin
  perform private.require_admin();
  v_id:=private.begin_operation(p_request,'review_agency',jsonb_build_array(p_verification,p_approved,p_reason));
  if v_id is not null then return v_id; end if;
  if p_approved is null then raise exception 'Decision required' using errcode='22023'; end if;
  select agency_id into strict v_agency from public.agency_verifications where id=p_verification;
  perform 1 from public.agencies where id=v_agency for update;
  select status into strict v_status from public.agency_verifications where id=p_verification for update;
  if v_status<>'pending' then raise exception 'Verification already reviewed' using errcode='23514'; end if;
  update public.agency_verifications set status=case when p_approved then 'approved' else 'rejected' end,
    reviewed_by=auth.uid(),reviewed_at=clock_timestamp(),review_note=p_reason where id=p_verification;
  update public.agencies set approval_status=case when p_approved then 'approved' else 'rejected' end where id=v_agency;
  insert into public.agency_approval_records(agency_id,verification_id,decision,reviewer_id,reason,request_id)
    values(v_agency,p_verification,case when p_approved then 'approved' else 'rejected' end,auth.uid(),p_reason,p_request) returning id into v_id;
  perform private.write_audit('agency_reviewed','agency_verifications',p_verification,v_agency,p_reason);
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function public.admin_set_agency_state(p_agency uuid,p_suspended boolean,p_reason text,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid;
begin
  perform private.require_admin();
  v_id:=private.begin_operation(p_request,'agency_state',jsonb_build_array(p_agency,p_suspended,p_reason));
  if v_id is not null then return v_id; end if;
  if p_suspended is null then raise exception 'State required' using errcode='22023'; end if;
  perform 1 from public.agencies where id=p_agency for update;
  if not found then raise exception 'Agency not found' using errcode='22023'; end if;
  update public.agencies set operational_status=case when p_suspended then 'suspended' else 'active' end where id=p_agency;
  insert into public.agency_approval_records(agency_id,decision,reviewer_id,reason,request_id)
    values(p_agency,case when p_suspended then 'suspended' else 'reactivated' end,auth.uid(),p_reason,p_request) returning id into v_id;
  perform private.write_audit('agency_state_changed','agencies',p_agency,p_agency,p_reason);
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function public.admin_create_plan_version(
  p_code text,p_name text,p_model text,p_price_minor bigint,p_can_publish boolean,
  p_listing_limit integer,p_analytics text,p_can_sponsor boolean,p_placement_limit integer,p_request uuid
) returns uuid language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; v_plan uuid; v_version integer;
begin
  perform private.require_admin();
  v_id:=private.begin_operation(p_request,'plan_version',jsonb_build_array(p_code,p_name,p_model,p_price_minor,p_can_publish,p_listing_limit,p_analytics,p_can_sponsor,p_placement_limit));
  if v_id is not null then return v_id; end if;
  insert into public.subscription_plans(code,name) values(p_code,p_name) on conflict(code) do nothing;
  select id into strict v_plan from public.subscription_plans where code=p_code for update;
  select coalesce(max(version),0)+1 into v_version from public.subscription_plan_versions where plan_id=v_plan;
  insert into public.subscription_plan_versions(plan_id,version,billing_model,price_minor,can_publish,max_published_packages,analytics_level,can_sponsor,max_active_placements)
    values(v_plan,v_version,p_model,p_price_minor,p_can_publish,p_listing_limit,p_analytics,p_can_sponsor,p_placement_limit) returning id into v_id;
  perform private.write_audit('plan_version_created','subscription_plan_versions',v_id,null);
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function public.admin_assign_subscription(
  p_agency uuid,p_plan_version uuid,p_starts timestamptz,p_ends timestamptz,p_reason text,p_request uuid
) returns uuid language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; v_plan public.subscription_plan_versions; v_count bigint;
begin
  perform private.require_admin();
  v_id:=private.begin_operation(p_request,'assign_subscription',jsonb_build_array(p_agency,p_plan_version,p_starts,p_ends,p_reason));
  if v_id is not null then return v_id; end if;
  perform 1 from public.agencies where id=p_agency for update;
  if not found then raise exception 'Agency not found' using errcode='22023'; end if;
  select v.* into strict v_plan from public.subscription_plan_versions v join public.subscription_plans p on p.id=v.plan_id where v.id=p_plan_version and p.is_active;
  if v_plan.price_minor is null then raise exception 'Configure plan price before assignment' using errcode='23514'; end if;
  if v_plan.billing_model='monthly' and p_ends is distinct from (((p_starts at time zone 'Asia/Kathmandu')+interval '1 month') at time zone 'Asia/Kathmandu') then
    raise exception 'Monthly subscriptions require one Nepal calendar month' using errcode='23514';
  end if;
  if v_plan.billing_model='annual' and p_ends is distinct from (((p_starts at time zone 'Asia/Kathmandu')+interval '1 year') at time zone 'Asia/Kathmandu') then
    raise exception 'Annual subscriptions require one Nepal calendar year' using errcode='23514';
  end if;
  select count(*) into v_count from public.packages where agency_id=p_agency and state='published';
  if v_plan.max_published_packages is not null and v_count>v_plan.max_published_packages then
    raise exception 'Pause excess listings before downgrade' using errcode='23514';
  end if;
  insert into public.agency_subscriptions(agency_id,plan_version_id,status,starts_at,ends_at,assigned_by,reason,request_id)
    values(p_agency,p_plan_version,'active',p_starts,p_ends,auth.uid(),p_reason,p_request) returning id into v_id;
  perform private.write_audit('subscription_assigned','agency_subscriptions',v_id,p_agency,p_reason);
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function public.admin_set_subscription_status(p_subscription uuid,p_status text,p_reason text,p_request uuid)
returns uuid language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; v_agency uuid;
begin
  perform private.require_admin();
  v_id:=private.begin_operation(p_request,'subscription_status',jsonb_build_array(p_subscription,p_status,p_reason));
  if v_id is not null then return v_id; end if;
  if p_status is null or p_status not in ('suspended','expired','cancelled') then
    raise exception 'Use a new assignment for activation or renewal' using errcode='22023';
  end if;
  select agency_id into strict v_agency from public.agency_subscriptions where id=p_subscription;
  perform 1 from public.agencies where id=v_agency for update;
  update public.agency_subscriptions set status=p_status where id=p_subscription;
  perform private.write_audit('subscription_status_changed','agency_subscriptions',p_subscription,v_agency,p_reason);
  return private.finish_operation(p_request,p_subscription);
end;
$fn$;

create function public.create_package(p_agency uuid,p_slug text,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid;
begin
  perform private.require_agency(p_agency);
  v_id:=private.begin_operation(p_request,'create_package',jsonb_build_array(p_agency,p_slug));
  if v_id is not null then return v_id; end if;
  insert into public.packages(agency_id,slug) values(p_agency,p_slug) returning id into v_id;
  perform private.write_audit('package_created','packages',v_id,p_agency);
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function private.assert_revision_ready(p_revision uuid) returns void
language plpgsql security definer set search_path = ''
as $fn$
declare r public.package_revisions;
begin
  select * into strict r from public.package_revisions where id=p_revision;
  if char_length(btrim(r.description))=0 or coalesce(char_length(btrim(r.source_note)),0)=0
    or not exists(select 1 from public.package_destinations where revision_id=r.id and is_primary)
    or exists(select 1 from public.package_destinations x join public.destinations d on d.id=x.destination_id where x.revision_id=r.id and not d.published)
    or not exists(select 1 from public.package_origins where revision_id=r.id)
    or not exists(select 1 from public.package_interests where revision_id=r.id)
    or (select count(*) from public.package_itinerary_days where revision_id=r.id)<>r.duration_days
    or exists(select 1 from public.package_itinerary_days where revision_id=r.id and day_number>r.duration_days)
    or not exists(select 1 from public.package_price_rules where revision_id=r.id and min_travelers>=r.min_travelers and max_travelers<=r.max_travelers)
    or exists(select 1 from public.package_price_rules where revision_id=r.id and (min_travelers<r.min_travelers or max_travelers>r.max_travelers))
  then raise exception 'Complete and validate package content before review' using errcode='23514'; end if;
end;
$fn$;

create function public.submit_package_revision(p_revision uuid,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; r public.package_revisions;
begin
  select * into strict r from public.package_revisions where id=p_revision;
  perform private.require_agency(r.agency_id);
  v_id:=private.begin_operation(p_request,'submit_revision',jsonb_build_array(p_revision));
  if v_id is not null then return v_id; end if;
  select * into strict r from public.package_revisions where id=p_revision for update;
  if r.status<>'draft' then raise exception 'Only drafts can be submitted' using errcode='23514'; end if;
  perform private.assert_revision_ready(p_revision);
  update public.package_revisions set status='pending_review' where id=p_revision;
  perform private.write_audit('revision_submitted','package_revisions',p_revision,r.agency_id);
  return private.finish_operation(p_request,p_revision);
end;
$fn$;

create function public.admin_review_package(p_revision uuid,p_approved boolean,p_reason text,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; r public.package_revisions;
begin
  perform private.require_admin();
  v_id:=private.begin_operation(p_request,'review_revision',jsonb_build_array(p_revision,p_approved,p_reason));
  if v_id is not null then return v_id; end if;
  if p_approved is null then raise exception 'Decision required' using errcode='22023'; end if;
  select * into strict r from public.package_revisions where id=p_revision for update;
  if r.status<>'pending_review' then raise exception 'Revision is not pending review' using errcode='23514'; end if;
  if p_approved then perform private.assert_revision_ready(p_revision); end if;
  update public.package_revisions set status=case when p_approved then 'approved' else 'rejected' end,
    reviewed_by=auth.uid(),reviewed_at=clock_timestamp() where id=p_revision;
  insert into public.package_review_records(revision_id,agency_id,decision,reviewer_id,reason,request_id)
    values(p_revision,r.agency_id,case when p_approved then 'approved' else 'rejected' end,auth.uid(),p_reason,p_request) returning id into v_id;
  perform private.write_audit('revision_reviewed','package_revisions',p_revision,r.agency_id,p_reason);
  return private.finish_operation(p_request,v_id);
end;
$fn$;

create function public.publish_package(p_package uuid,p_revision uuid,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; p public.packages; ent public.subscription_plan_versions; v_count bigint;
begin
  select * into strict p from public.packages where id=p_package;
  perform private.require_agency(p.agency_id);
  v_id:=private.begin_operation(p_request,'publish_package',jsonb_build_array(p_package,p_revision));
  if v_id is not null then return v_id; end if;
  -- All publishing, quota, subscription and suspension transitions take this lock first.
  perform 1 from public.agencies where id=p.agency_id and approval_status='approved' and operational_status='active' for update;
  if not found then raise exception 'Approved active agency required' using errcode='23514'; end if;
  select * into strict p from public.packages where id=p_package for update;
  select * into ent from private.effective_plan(p.agency_id);
  if not found then raise exception 'Eligible subscription required' using errcode='23514'; end if;
  perform 1 from public.package_revisions where id=p_revision and package_id=p.id and agency_id=p.agency_id and status='approved';
  if not found then raise exception 'Approved owned revision required' using errcode='23514'; end if;
  perform private.assert_revision_ready(p_revision);
  select count(*) into v_count from public.packages where agency_id=p.agency_id and state='published' and id<>p.id;
  if ent.max_published_packages is not null and v_count>=ent.max_published_packages then
    raise exception 'Published listing limit reached' using errcode='23514';
  end if;
  update public.packages set state='published',published_revision_id=p_revision,
    reconfirmed_revision_id=p_revision,last_reconfirmed_at=statement_timestamp() where id=p.id;
  if not private.package_visible(p.id) then raise exception 'Package lacks current eligible pricing' using errcode='23514'; end if;
  perform private.write_audit('package_published','packages',p.id,p.agency_id);
  return private.finish_operation(p_request,p.id);
end;
$fn$;

create function public.pause_package(p_package uuid,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; v_agency uuid;
begin
  select agency_id into strict v_agency from public.packages where id=p_package;
  perform private.require_agency(v_agency);
  v_id:=private.begin_operation(p_request,'pause_package',jsonb_build_array(p_package));
  if v_id is not null then return v_id; end if;
  perform 1 from public.agencies where id=v_agency for update;
  update public.packages set state='paused' where id=p_package;
  perform private.write_audit('package_paused','packages',p_package,v_agency);
  return private.finish_operation(p_request,p_package);
end;
$fn$;

create function public.reconfirm_package(p_package uuid,p_request uuid) returns uuid
language plpgsql security definer set search_path = ''
as $fn$
declare v_id uuid; p public.packages;
begin
  select * into strict p from public.packages where id=p_package;
  perform private.require_agency(p.agency_id);
  v_id:=private.begin_operation(p_request,'reconfirm_package',jsonb_build_array(p_package,p.published_revision_id));
  if v_id is not null then return v_id; end if;
  perform 1 from public.agencies where id=p.agency_id for update;
  select * into strict p from public.packages where id=p_package for update;
  if p.state<>'published' then raise exception 'Only a published revision can be reconfirmed' using errcode='23514'; end if;
  update public.packages set last_reconfirmed_at=statement_timestamp(),reconfirmed_revision_id=p.published_revision_id where id=p.id;
  perform private.write_audit('package_reconfirmed','packages',p.id,p.agency_id);
  return private.finish_operation(p_request,p.id);
end;
$fn$;

revoke all on function private.begin_operation(uuid,text,jsonb) from public,anon,authenticated,service_role;
revoke all on function private.finish_operation(uuid,uuid) from public,anon,authenticated,service_role;
revoke all on function public.ensure_profile() from public,anon,authenticated,service_role;
grant execute on function public.ensure_profile() to authenticated;
revoke all on function public.register_agency(text,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.register_agency(text,text,uuid) to authenticated;
revoke all on function public.submit_agency_verification(uuid,text,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.submit_agency_verification(uuid,text,text,uuid) to authenticated;
revoke all on function public.admin_review_agency(uuid,boolean,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.admin_review_agency(uuid,boolean,text,uuid) to authenticated;
revoke all on function public.admin_set_agency_state(uuid,boolean,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.admin_set_agency_state(uuid,boolean,text,uuid) to authenticated;
revoke all on function public.admin_create_plan_version(text,text,text,bigint,boolean,integer,text,boolean,integer,uuid) from public,anon,authenticated,service_role;
grant execute on function public.admin_create_plan_version(text,text,text,bigint,boolean,integer,text,boolean,integer,uuid) to authenticated;
revoke all on function public.admin_assign_subscription(uuid,uuid,timestamptz,timestamptz,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.admin_assign_subscription(uuid,uuid,timestamptz,timestamptz,text,uuid) to authenticated;
revoke all on function public.admin_set_subscription_status(uuid,text,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.admin_set_subscription_status(uuid,text,text,uuid) to authenticated;
revoke all on function public.create_package(uuid,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.create_package(uuid,text,uuid) to authenticated;
revoke all on function private.assert_revision_ready(uuid) from public,anon,authenticated,service_role;
revoke all on function public.submit_package_revision(uuid,uuid) from public,anon,authenticated,service_role;
grant execute on function public.submit_package_revision(uuid,uuid) to authenticated;
revoke all on function public.admin_review_package(uuid,boolean,text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.admin_review_package(uuid,boolean,text,uuid) to authenticated;
revoke all on function public.publish_package(uuid,uuid,uuid) from public,anon,authenticated,service_role;
grant execute on function public.publish_package(uuid,uuid,uuid) to authenticated;
revoke all on function public.pause_package(uuid,uuid) from public,anon,authenticated,service_role;
grant execute on function public.pause_package(uuid,uuid) to authenticated;
revoke all on function public.reconfirm_package(uuid,uuid) from public,anon,authenticated,service_role;
grant execute on function public.reconfirm_package(uuid,uuid) to authenticated;
commit;
