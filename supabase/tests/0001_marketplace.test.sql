-- DEFERRED INTEGRATION TESTS. Never run on production.
-- Only after explicit approval, application of the reviewed migrations, and:
-- set ghumne.allow_test_fixtures = 'yes';
-- All agencies, users, prices and dates below are SYNTHETIC TEST FIXTURES.
begin;
do $guard$
begin
  if current_setting('ghumne.allow_test_fixtures',true) is distinct from 'yes' then
    raise exception 'An explicitly approved isolated test database is required';
  end if;
end;
$guard$;
create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to anon,authenticated,service_role;
set local search_path = public,extensions,pg_catalog;
select no_plan();

create function pg_temp.actor(p_id uuid,p_role text default 'authenticated') returns void
language plpgsql as $fn$
begin
  perform set_config('request.jwt.claim.sub',coalesce(p_id::text,''),true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',p_id,'role',p_role)::text,true);
end;
$fn$;
-- Test helpers/fixtures exist only inside this rolled-back transaction.
insert into auth.users(id,aud,role,email,raw_app_meta_data,raw_user_meta_data)
select id::uuid,'authenticated','authenticated',email,'{}'::jsonb,metadata::jsonb
from (values
 ('00000000-0000-0000-0000-000000000001','synthetic-admin@example.invalid','{}'),
 ('00000000-0000-0000-0000-000000000002','synthetic-owner-a@example.invalid','{}'),
 ('00000000-0000-0000-0000-000000000003','synthetic-owner-b@example.invalid','{"role":"admin"}'),
 ('00000000-0000-0000-0000-000000000004','synthetic-traveler-a@example.invalid','{}'),
 ('00000000-0000-0000-0000-000000000005','synthetic-traveler-b@example.invalid','{}')
) f(id,email,metadata);
insert into public.user_roles(user_id,role) values
 ('00000000-0000-0000-0000-000000000001','admin'),
 ('00000000-0000-0000-0000-000000000002','agency'),
 ('00000000-0000-0000-0000-000000000003','agency');
insert into public.agencies(id,name,slug) values
 ('10000000-0000-0000-0000-000000000001','Synthetic Agency A (TEST ONLY)','synthetic-test-a'),
 ('10000000-0000-0000-0000-000000000002','Synthetic Agency B (TEST ONLY)','synthetic-test-b');
insert into public.agency_memberships(agency_id,user_id) values
 ('10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002'),
 ('10000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003');
insert into public.agency_verifications(id,agency_id,submitted_by,business_registration_reference) values
 ('80000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002','SYNTHETIC EVIDENCE A'),
 ('80000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003','SYNTHETIC EVIDENCE B');
insert into public.locations(id,name,slug) values('50000000-0000-0000-0000-000000000001','Synthetic Origin','synthetic-origin');
insert into public.destinations(id,name,slug,min_days,max_days,published,source_note)
values('40000000-0000-0000-0000-000000000001','Synthetic Destination','synthetic-destination',1,5,true,'TEST ONLY');
insert into public.interests(id,name,slug) values('60000000-0000-0000-0000-000000000001','Synthetic Interest','synthetic-interest');
insert into public.packages(id,agency_id,slug) values
 ('20000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','synthetic-offer-a'),
 ('20000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','synthetic-offer-b'),
 ('20000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000001','synthetic-over-limit');
insert into public.package_revisions(id,package_id,agency_id,version,title,description,duration_days,nights,min_travelers,max_travelers,necessary_exclusions_unpriced,source_note)
select ('30000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,
       ('20000000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,
       ('10000000-0000-0000-0000-'||lpad(case when n=2 then '2' else '1' end,12,'0'))::uuid,
       1,'Synthetic Offer '||n,'SYNTHETIC TEST DATA, NOT A LIVE OFFER',3,2,1,10,false,'SYNTHETIC TEST SOURCE'
from generate_series(1,3) n;
insert into public.package_destinations(revision_id,agency_id,destination_id,stop_order,is_primary)
select id,agency_id,'40000000-0000-0000-0000-000000000001',0,true from public.package_revisions;
insert into public.package_origins(revision_id,agency_id,location_id)
select id,agency_id,'50000000-0000-0000-0000-000000000001' from public.package_revisions;
insert into public.package_interests(revision_id,agency_id,interest_id)
select id,agency_id,'60000000-0000-0000-0000-000000000001' from public.package_revisions;
insert into public.package_itinerary_days(revision_id,agency_id,day_number,title)
select r.id,r.agency_id,n,'Synthetic day '||n from public.package_revisions r cross join generate_series(1,3) n;
insert into public.package_price_rules(id,revision_id,agency_id,basis,base_minor,min_travelers,max_travelers,sales_from,sales_until,source_note)
select ('70000000-0000-0000-0000-'||lpad(r.version::text||right(r.id::text,1),12,'0'))::uuid,
       r.id,r.agency_id,case when right(r.id::text,1)='2' then 'per_group' else 'per_person' end,
       case when right(r.id::text,1)='2' then 1200000 else 500000 end,
       1,10,statement_timestamp()-interval '1 day',statement_timestamp()+interval '60 days','SYNTHETIC TEST PRICE'
from public.package_revisions r;
insert into public.package_price_components(price_rule_id,revision_id,agency_id,label,classification,amount_minor,unit,frequency)
select id,revision_id,agency_id,'Synthetic group fee','mandatory',60000,'group','trip'
from public.package_price_rules where basis='per_person';

select is((private.calculate_group_price(500000,'per_person',3,3,2,
  '[{"classification":"mandatory","amount_minor":60000,"unit":"group","frequency":"trip"}]')->>'total_minor')::bigint,1560000::bigint,'per-person base plus one group fee');
select is((private.calculate_group_price(1200000,'per_group',3,3,2,'[]')->>'total_minor')::bigint,1200000::bigint,'group total is not multiplied by travelers');
select is((private.calculate_group_price(0,'per_group',3,3,2,
  '[{"classification":"mandatory","amount_minor":100,"unit":"person","frequency":"night"}]')->>'total_minor')::bigint,600::bigint,'person-night quantities use travelers and nights');
select is((private.calculate_group_price(100,'per_group',3,3,2,
  '[{"classification":"included","amount_minor":500,"unit":"person","frequency":"day"},{"classification":"optional","amount_minor":900,"unit":"group","frequency":"trip"}]')->>'total_minor')::bigint,100::bigint,'included and optional fees are not double-counted');
select is(private.calculate_group_price(100,'per_group',3,3,2,
  '[{"classification":"mandatory","amount_minor":null,"unit":"group","frequency":"trip"}]')->>'reason','unpriced_required_charge','unknown mandatory fees are not zero');
select throws_ok($$select private.calculate_group_price(9000000000000000,'per_person',2,3,2,'[]')$$,'22003',null,'overflow is rejected');
select throws_ok($$select private.calculate_group_price(1,'per_person',0,3,2,'[]')$$,'22023',null,'zero travelers are rejected');
select throws_ok($$select private.calculate_group_price(1,'per_person',1,0,0,'[]')$$,'22023',null,'invalid days are rejected');

select pg_temp.actor('00000000-0000-0000-0000-000000000002');
set local role authenticated;
select is((select count(*)::integer from public.agencies),1,'agency A reads only its tenant');
select is((select count(*)::integer from public.package_revisions),2,'agency A cannot read agency B drafts');
select throws_ok($$insert into public.user_roles(user_id,role) values('00000000-0000-0000-0000-000000000002','admin')$$,'42501',null,'agency cannot grant itself admin');
select throws_ok($$update public.agencies set approval_status='approved' where id='10000000-0000-0000-0000-000000000001'$$,'42501',null,'agency cannot self-approve');
select throws_ok($$update public.packages set state='published' where id='20000000-0000-0000-0000-000000000001'$$,'42501',null,'agency cannot bypass publication RPC');
select throws_ok($$insert into public.agency_subscriptions(agency_id) values('10000000-0000-0000-0000-000000000001')$$,'42501',null,'agency cannot activate subscription');
select throws_ok($$select public.admin_review_agency('80000000-0000-0000-0000-000000000001',true,'test',gen_random_uuid())$$,'42501',null,'server-side admin check rejects agency');
select throws_ok($$select public.create_package('10000000-0000-0000-0000-000000000002','foreign-draft',gen_random_uuid())$$,'42501',null,'agency A cannot mutate agency B');
select throws_ok($$insert into public.package_price_components(price_rule_id,revision_id,agency_id,label,classification,amount_minor,unit,frequency)
  values('70000000-0000-0000-0000-000000000012','30000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','foreign rule','mandatory',1,'group','trip')$$,
  '23503',null,'same-tenant composite foreign key rejects foreign price rule');
select throws_ok($$insert into public.package_price_rules(revision_id,agency_id,basis,base_minor,min_travelers,max_travelers,sales_from,sales_until,source_note)
  values('30000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','per_person',1,1,10,statement_timestamp(),statement_timestamp()+interval '1 day','TEST')$$,
  '23P01',null,'overlapping price tiers are rejected');
select is(public.create_package('10000000-0000-0000-0000-000000000001','idempotent-draft','90000000-0000-0000-0000-000000000001'),
  public.create_package('10000000-0000-0000-0000-000000000001','idempotent-draft','90000000-0000-0000-0000-000000000001'),'same request returns same package');
select throws_ok($$select public.create_package('10000000-0000-0000-0000-000000000001','different-draft','90000000-0000-0000-0000-000000000001')$$,
  '22023',null,'idempotency key cannot be reused for another payload');
select throws_ok($$select public.publish_package('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001',gen_random_uuid())$$,
  '23514',null,'unapproved agency cannot publish');
select lives_ok($$select public.submit_package_revision('30000000-0000-0000-0000-000000000001',gen_random_uuid())$$,'agency A submits a complete draft for review');
select lives_ok($$select public.submit_package_revision('30000000-0000-0000-0000-000000000003',gen_random_uuid())$$,'second A draft submitted');
select pg_temp.actor('00000000-0000-0000-0000-000000000003');
select ok(not exists(select 1 from public.user_roles where user_id='00000000-0000-0000-0000-000000000003' and role='admin'),'raw signup metadata did not grant admin');
select lives_ok($$select public.submit_package_revision('30000000-0000-0000-0000-000000000002',gen_random_uuid())$$,'agency B submits its own revision');
reset role;

select pg_temp.actor('00000000-0000-0000-0000-000000000001');
set local role authenticated;
select lives_ok($$select public.admin_review_agency('80000000-0000-0000-0000-000000000001',true,'SYNTHETIC manual review',gen_random_uuid())$$,'admin approves A manually');
select lives_ok($$select public.admin_review_agency('80000000-0000-0000-0000-000000000002',true,'SYNTHETIC manual review',gen_random_uuid())$$,'admin approves B manually');
select set_config('test.plan_version',public.admin_create_plan_version('synthetic_pilot','Synthetic Pilot','free_pilot',0,true,1,'basic',true,1,gen_random_uuid())::text,true);
select set_config('test.subscription_a',public.admin_assign_subscription('10000000-0000-0000-0000-000000000001',current_setting('test.plan_version')::uuid,
  statement_timestamp()-interval '1 day',statement_timestamp()+interval '60 days','SYNTHETIC PILOT',gen_random_uuid())::text,true);
select lives_ok($$select public.admin_assign_subscription('10000000-0000-0000-0000-000000000002',current_setting('test.plan_version')::uuid,
  statement_timestamp()-interval '1 day',statement_timestamp()+interval '60 days','SYNTHETIC PILOT',gen_random_uuid())$$,'admin assigns B pilot entitlement');
select set_config('test.monthly',public.admin_create_plan_version('synthetic_monthly','Synthetic Monthly','monthly',100,true,1,'basic',false,0,gen_random_uuid())::text,true);
select set_config('test.annual',public.admin_create_plan_version('synthetic_annual','Synthetic Annual','annual',100,true,1,'basic',false,0,gen_random_uuid())::text,true);
select throws_ok($$select public.admin_assign_subscription('10000000-0000-0000-0000-000000000002',current_setting('test.monthly')::uuid,
  statement_timestamp()+interval '90 days',statement_timestamp()+interval '91 days','SYNTHETIC TERM',gen_random_uuid())$$,'23514',null,'monthly plan rejects a one-day term');
select lives_ok($$select public.admin_assign_subscription('10000000-0000-0000-0000-000000000002',current_setting('test.monthly')::uuid,
  statement_timestamp()+interval '90 days',(((statement_timestamp()+interval '90 days') at time zone 'Asia/Kathmandu')+interval '1 month') at time zone 'Asia/Kathmandu',
  'SYNTHETIC MONTH',gen_random_uuid())$$,'monthly plan accepts one Nepal calendar month');
select throws_ok($$select public.admin_assign_subscription('10000000-0000-0000-0000-000000000002',current_setting('test.annual')::uuid,
  statement_timestamp()+interval '2 years',statement_timestamp()+interval '2 years 1 day','SYNTHETIC TERM',gen_random_uuid())$$,'23514',null,'annual plan rejects a one-day term');
select lives_ok($$select public.admin_assign_subscription('10000000-0000-0000-0000-000000000002',current_setting('test.annual')::uuid,
  statement_timestamp()+interval '2 years',(((statement_timestamp()+interval '2 years') at time zone 'Asia/Kathmandu')+interval '1 year') at time zone 'Asia/Kathmandu',
  'SYNTHETIC YEAR',gen_random_uuid())$$,'annual plan accepts one Nepal calendar year');
select throws_ok($$update public.subscription_plan_versions set price_minor=999 where id=current_setting('test.monthly')::uuid$$,'42501',null,'assigned plan terms cannot be mutated directly');
select throws_ok($$select public.admin_assign_subscription('10000000-0000-0000-0000-000000000001',current_setting('test.plan_version')::uuid,
  statement_timestamp(),statement_timestamp()+interval '1 day','SYNTHETIC overlap',gen_random_uuid())$$,'23P01',null,'overlapping active subscriptions are rejected');
select lives_ok($$select public.admin_review_package('30000000-0000-0000-0000-000000000001',true,'SYNTHETIC review',gen_random_uuid())$$,'admin approves A revision');
select lives_ok($$select public.admin_review_package('30000000-0000-0000-0000-000000000002',true,'SYNTHETIC review',gen_random_uuid())$$,'admin approves B revision');
select lives_ok($$select public.admin_review_package('30000000-0000-0000-0000-000000000003',true,'SYNTHETIC review',gen_random_uuid())$$,'second A revision can be approved without publishing');
reset role;

select pg_temp.actor('00000000-0000-0000-0000-000000000002');
set local role authenticated;
select lives_ok($$select public.publish_package('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001',gen_random_uuid())$$,'approved subscribed agency can publish');
select throws_ok($$select public.publish_package('20000000-0000-0000-0000-000000000003','30000000-0000-0000-0000-000000000003',gen_random_uuid())$$,
  '23514',null,'listing quota rejects a second publication');
select throws_ok($$insert into public.package_price_components(price_rule_id,revision_id,agency_id,label,classification,amount_minor,unit,frequency)
  values('70000000-0000-0000-0000-000000000011','30000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','unreviewed fee','mandatory',1,'group','trip')$$,
  '42501',null,'agency cannot alter approved revision child content');
select lives_ok($$select public.set_package_availability('30000000-0000-0000-0000-000000000001',null,'fixed_departure',
  (statement_timestamp() at time zone 'Asia/Kathmandu')::date+10,(statement_timestamp() at time zone 'Asia/Kathmandu')::date+12,
  'open',10,'SYNTHETIC confirmation',gen_random_uuid())$$,'owner confirms capacity and dates separately');
select pg_temp.actor('00000000-0000-0000-0000-000000000003');
select lives_ok($$select public.publish_package('20000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000002',gen_random_uuid())$$,'second agency can publish same destination');
reset role;

select pg_temp.actor(null,'anon');
set local role anon;
select is(jsonb_array_length(public.catalog_packages('40000000-0000-0000-0000-000000000001')),2,'both agencies automatically enter destination catalog');
select throws_ok($$select * from public.package_revisions$$,'42501',null,'anonymous cannot query raw package revisions');
select throws_ok($$select * from public.inquiries$$,'42501',null,'anonymous cannot read contacts');
select is((public.quote_package('20000000-0000-0000-0000-000000000001',3)->>'total_minor')::bigint,1560000::bigint,'public quote calculates entire group total');
select is(public.quote_package('20000000-0000-0000-0000-000000000001',3)->>'availability_status','not_checked','undated quote does not imply availability');
select is(public.quote_package('20000000-0000-0000-0000-000000000001',3,
  (statement_timestamp() at time zone 'Asia/Kathmandu')::date+10)->>'availability_status','agency_confirmed','matching dates/capacity confirmed');
select is(public.quote_package('20000000-0000-0000-0000-000000000001',3,
  (statement_timestamp() at time zone 'Asia/Kathmandu')::date+11)->>'availability_status','requires_confirmation','other dates are not invented');
select is(public.quote_package('20000000-0000-0000-0000-000000000001',11)->>'reason','group_size_mismatch','out-of-tier groups are not quoted');
select throws_ok($$select public.submit_inquiry('20000000-0000-0000-0000-000000000001',3,null,'TEST','test@example.invalid',null,'TEST','v1',repeat('a',64),gen_random_uuid(),null)$$,
  '42501',null,'guest cannot directly invoke backend-only inquiry RPC');
reset role;

select pg_temp.actor('00000000-0000-0000-0000-000000000001');
set local role authenticated;
select lives_ok($$select public.admin_create_placement('20000000-0000-0000-0000-000000000001','search',null,
  statement_timestamp()-interval '1 hour',statement_timestamp()+interval '1 day',gen_random_uuid())$$,'admin creates entitled placement');
reset role;
select pg_temp.actor(null,'anon');
set local role anon;
select is(public.sponsored_packages('search')->0->>'label','Sponsored','every returned placement has a Sponsored label');
select is(jsonb_array_length(public.catalog_packages()),2,'sponsorship does not remove organic eligibility');
reset role;

select pg_temp.actor('00000000-0000-0000-0000-000000000004');
set local role authenticated;
insert into public.trips(id,user_id,title,destination_id,origin_id,days,nights,travelers,budget_total_minor)
values('a0000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000004','Synthetic Private Plan',
  '40000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001',3,2,3,2000000);
insert into public.trip_days(trip_id,user_id,day_number,title,notes)
values('a0000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000004',1,'Public day title','PRIVATE_NOTE_TEST');
select lives_ok($$select public.save_package_comparison('a0000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001',gen_random_uuid())$$,'traveler saves recalculated comparison');
select set_config('test.share',public.create_trip_share('a0000000-0000-0000-0000-000000000001',encode(sha256(convert_to(repeat('x',43),'UTF8')),'hex'),null,gen_random_uuid())::text,true);
select pg_temp.actor('00000000-0000-0000-0000-000000000005');
select is((select count(*)::integer from public.trips),0,'traveler B cannot read A trip');
select is((select count(*)::integer from public.trip_package_comparisons),0,'traveler B cannot read A comparison');
select throws_ok($$select public.create_trip_share('a0000000-0000-0000-0000-000000000001',repeat('c',64),null,gen_random_uuid())$$,
  '42501',null,'traveler B cannot share A trip');
reset role;
select pg_temp.actor(null,'anon');
set local role anon;
select ok(public.shared_trip(repeat('x',43)) is not null,'bearer share exposes intended safe projection');
select ok(public.shared_trip(repeat('x',43))::text not like '%PRIVATE_NOTE_TEST%','share excludes private notes');
select ok(not (public.shared_trip(repeat('x',43)) ? 'user_id'),'share excludes traveler identity');
reset role;
select pg_temp.actor('00000000-0000-0000-0000-000000000004');
set local role authenticated;
select lives_ok($$select public.revoke_trip_share(current_setting('test.share')::uuid)$$,'traveler revokes own share');
reset role;
select pg_temp.actor(null,'anon');
set local role anon;
select ok(public.shared_trip(repeat('x',43)) is null,'revocation immediately removes bearer access');
reset role;

-- Short-lived technical rate-limit default is configurable, not commercial pricing.
update public.retention_policies set retain_days=30,policy_note='SYNTHETIC TEST POLICY ONLY' where data_category='inquiries';
update public.marketplace_settings set inquiry_hourly_limit=1,inquiries_enabled=true;
select pg_temp.actor(null,'service_role');
set local role service_role;
select set_config('test.inquiry',public.submit_inquiry('20000000-0000-0000-0000-000000000001',3,null,'Synthetic Traveler',
  'synthetic-inquiry@example.invalid',null,'SYNTHETIC inquiry','synthetic-consent-v1',repeat('a',64),
  '90000000-0000-0000-0000-000000000099','00000000-0000-0000-0000-000000000004')::text,true);
select is(public.submit_inquiry('20000000-0000-0000-0000-000000000001',3,null,'Synthetic Traveler',
  'synthetic-inquiry@example.invalid',null,'SYNTHETIC inquiry','synthetic-consent-v1',repeat('a',64),
  '90000000-0000-0000-0000-000000000099','00000000-0000-0000-0000-000000000004')::text,current_setting('test.inquiry'),'retry returns same inquiry without consuming rate allowance');
select throws_ok($$select public.submit_inquiry('20000000-0000-0000-0000-000000000001',3,null,'Synthetic Traveler',
  'synthetic-inquiry@example.invalid',null,'SYNTHETIC inquiry','synthetic-consent-v1',repeat('a',64),gen_random_uuid(),null)$$,
  'P0001',null,'durable rate limit rejects another inquiry');
reset role;
select pg_temp.actor('00000000-0000-0000-0000-000000000002');
set local role authenticated;
select is((select count(*)::integer from public.inquiries),1,'owning agency sees inquiry');
select is((select agency_id from public.inquiries limit 1),'10000000-0000-0000-0000-000000000001'::uuid,'inquiry tenant derives from package');
select pg_temp.actor('00000000-0000-0000-0000-000000000003');
select is((select count(*)::integer from public.inquiries),0,'another agency cannot see inquiry');
select throws_ok($$select public.update_inquiry_status(current_setting('test.inquiry')::uuid,'closed',gen_random_uuid())$$,'42501',null,'another agency cannot mutate inquiry');
reset role;

-- Trusted test-owner simulation of elapsed time; no production data is touched.
update public.packages set last_reconfirmed_at=statement_timestamp()-interval '31 days' where id='20000000-0000-0000-0000-000000000001';
select pg_temp.actor(null,'anon');
set local role anon;
select ok(public.package_detail('20000000-0000-0000-0000-000000000001') is null,'31-day-old reconfirmation hides package');
reset role;
select pg_temp.actor('00000000-0000-0000-0000-000000000002');
set local role authenticated;
select lives_ok($$select public.reconfirm_package('20000000-0000-0000-0000-000000000001',gen_random_uuid())$$,'owner can reconfirm without material edits');
reset role;
select pg_temp.actor(null,'anon');
set local role anon;
select ok(public.package_detail('20000000-0000-0000-0000-000000000001') is not null,'reconfirmation restores eligible package');
reset role;

-- Status is deliberately still active: time expiry must independently hide offers.
update public.agency_subscriptions set starts_at=statement_timestamp()-interval '61 days',ends_at=statement_timestamp()-interval '1 day'
  where id=current_setting('test.subscription_a')::uuid;
select pg_temp.actor(null,'anon');
set local role anon;
select ok(public.package_detail('20000000-0000-0000-0000-000000000001') is null,'elapsed subscription period hides offer even with active status');
reset role;
update public.agency_subscriptions set starts_at=statement_timestamp()-interval '1 day',ends_at=statement_timestamp()+interval '60 days'
  where id=current_setting('test.subscription_a')::uuid;
select pg_temp.actor(null,'anon');
set local role anon;
select ok(public.package_detail('20000000-0000-0000-0000-000000000001') is not null,'valid period restores unchanged eligible data');
reset role;
select pg_temp.actor('00000000-0000-0000-0000-000000000001');
set local role authenticated;
select lives_ok($$select public.admin_set_subscription_status(current_setting('test.subscription_a')::uuid,'expired','SYNTHETIC expiry',gen_random_uuid())$$,'admin records expiry without deletion');
reset role;
select pg_temp.actor(null,'anon');
set local role anon;
select ok(public.package_detail('20000000-0000-0000-0000-000000000001') is null,'expired subscription removes direct public visibility');
select is(jsonb_array_length(public.sponsored_packages('search')),0,'expired subscription also removes sponsored placement');
select is(jsonb_array_length(public.catalog_packages()),1,'other subscribed agency remains visible');
reset role;
select pg_temp.actor('00000000-0000-0000-0000-000000000002');
set local role authenticated;
select ok((select count(*) from public.packages)>0,'expired agency retains its package data');
select is((select count(*)::integer from public.inquiries),1,'expired agency retains own inquiries');
reset role;

select ok(not exists(
  select 1 from pg_catalog.pg_class c join pg_catalog.pg_namespace n on n.oid=c.relnamespace
  where n.nspname in ('public','private') and c.relkind='r' and c.relname in (
    'profiles','user_roles','agencies','agency_memberships','agency_subscriptions','packages','package_revisions','package_price_rules','package_availability',
    'trips','trip_days','trip_items','trip_package_comparisons','inquiries','featured_placements','audit_logs','operation_requests'
  ) and not c.relrowsecurity
),'RLS is enabled on all security-critical tables');
select * from finish();
rollback;
