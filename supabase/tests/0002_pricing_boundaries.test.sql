-- DEFERRED INTEGRATION TESTS. Never run on production.
-- Additive suite: the original 81 assertions in 0001 are unchanged.
-- V1 discounts mean reviewed group tiers, not coupons/negative fees.
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

-- All fixtures, helpers and prices are synthetic and roll back with this file.
create function pg_temp.fixture_id(p_kind integer,p_n integer) returns uuid
language sql immutable as $fn$
  select ('fa'||lpad(p_kind::text,6,'0')||'-0000-4000-8000-'||lpad(p_n::text,12,'0'))::uuid;
$fn$;
create function pg_temp.actor(p_n integer) returns void language plpgsql as $fn$
begin
  perform set_config('request.jwt.claim.sub',pg_temp.fixture_id(1,p_n)::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',pg_temp.fixture_id(1,p_n),'role','authenticated')::text,true);
end;
$fn$;
insert into auth.users(id,aud,role,email,raw_app_meta_data,raw_user_meta_data)
select pg_temp.fixture_id(1,n),'authenticated','authenticated','boundary-'||n||'@example.invalid','{}',
  case when n=3 then '{"role":"admin"}'::jsonb else '{}'::jsonb end
from generate_series(1,3) n;
insert into public.user_roles(user_id,role) values
  (pg_temp.fixture_id(1,1),'admin'),(pg_temp.fixture_id(1,2),'agency'),(pg_temp.fixture_id(1,3),'agency');
insert into public.agencies(id,name,slug)
select pg_temp.fixture_id(2,n),'Synthetic Boundary Agency '||n,'synthetic-boundary-'||n from generate_series(1,2) n;
insert into public.agency_memberships(agency_id,user_id)
select pg_temp.fixture_id(2,n),pg_temp.fixture_id(1,n+1) from generate_series(1,2) n;
insert into public.agency_verifications(id,agency_id,submitted_by,business_registration_reference)
select pg_temp.fixture_id(3,n),pg_temp.fixture_id(2,n),pg_temp.fixture_id(1,n+1),'SYNTHETIC EVIDENCE ONLY' from generate_series(1,2) n;
insert into public.locations(id,name,slug) values(pg_temp.fixture_id(4,1),'Synthetic Boundary Origin','synthetic-boundary-origin');
insert into public.destinations(id,name,slug,min_days,max_days,published,source_note)
values(pg_temp.fixture_id(5,1),'Synthetic Boundary Destination','synthetic-boundary-destination',1,365,true,'TEST ONLY');
insert into public.interests(id,name,slug) values(pg_temp.fixture_id(6,1),'Synthetic Boundary Interest','synthetic-boundary-interest');

-- Minimal complete draft. Only the trusted fixture owner calls this helper.
create function pg_temp.offer(p_n integer,p_agency integer default 1,p_basis text default 'per_person',p_max integer default 10)
returns uuid language plpgsql as $fn$
declare v_revision uuid:=pg_temp.fixture_id(8,p_n); v_agency uuid:=pg_temp.fixture_id(2,p_agency);
begin
  insert into public.packages(id,agency_id,slug) values(pg_temp.fixture_id(7,p_n),v_agency,'synthetic-boundary-offer-'||p_n);
  insert into public.package_revisions(id,package_id,agency_id,version,title,description,duration_days,nights,min_travelers,max_travelers,necessary_exclusions_unpriced,source_note)
  values(v_revision,pg_temp.fixture_id(7,p_n),v_agency,1,'Synthetic boundary offer','SYNTHETIC TEST ONLY',3,2,1,p_max,false,'TEST ONLY');
  insert into public.package_destinations(revision_id,agency_id,destination_id,stop_order,is_primary) values(v_revision,v_agency,pg_temp.fixture_id(5,1),0,true);
  insert into public.package_origins(revision_id,agency_id,location_id) values(v_revision,v_agency,pg_temp.fixture_id(4,1));
  insert into public.package_interests(revision_id,agency_id,interest_id) values(v_revision,v_agency,pg_temp.fixture_id(6,1));
  insert into public.package_itinerary_days(revision_id,agency_id,day_number,title)
    select v_revision,v_agency,n,'Synthetic day '||n from generate_series(1,3) n;
  insert into public.package_price_rules(id,revision_id,agency_id,basis,base_minor,min_travelers,max_travelers,sales_from,sales_until,source_note)
  values(pg_temp.fixture_id(9,p_n),v_revision,v_agency,p_basis,100000,1,p_max,statement_timestamp()-interval '1 day',statement_timestamp()+interval '365 days','SYNTHETIC NPR MINOR UNITS');
  return v_revision;
end;
$fn$;
select pg_temp.offer(1);
select pg_temp.offer(2,2,'per_group');
select pg_temp.offer(3);
select pg_temp.offer(4);
-- Adjacent group tiers: a reviewed lower rate starts at exactly five travelers.
update public.package_price_rules set max_travelers=4 where id=pg_temp.fixture_id(9,1);
insert into public.package_price_rules(id,revision_id,agency_id,basis,base_minor,min_travelers,max_travelers,sales_from,sales_until,source_note)
values(pg_temp.fixture_id(9,101),pg_temp.fixture_id(8,1),pg_temp.fixture_id(2,1),'per_person',80000,5,10,
  statement_timestamp()-interval '1 day',statement_timestamp()+interval '365 days','SYNTHETIC GROUP TIER DISCOUNT');
insert into public.package_price_components(price_rule_id,revision_id,agency_id,label,classification,amount_minor,unit,frequency)
select id,revision_id,agency_id,'Synthetic mandatory group fee','mandatory',5000,'group','trip'
from public.package_price_rules where revision_id=pg_temp.fixture_id(8,1);
-- Per-group discounted tiers charge the group base once. Mandatory per-person
-- charges remain payable in full on both sides of the discount boundary.
update public.package_price_rules set max_travelers=4 where id=pg_temp.fixture_id(9,2);
insert into public.package_price_rules(id,revision_id,agency_id,basis,base_minor,min_travelers,max_travelers,sales_from,sales_until,source_note)
values(pg_temp.fixture_id(9,102),pg_temp.fixture_id(8,2),pg_temp.fixture_id(2,2),'per_group',90000,5,10,
  statement_timestamp()-interval '1 day',statement_timestamp()+interval '365 days','SYNTHETIC GROUP BASE DISCOUNT');
insert into public.package_price_components(price_rule_id,revision_id,agency_id,label,classification,amount_minor,unit,frequency)
select id,revision_id,agency_id,'Synthetic mandatory person fee','mandatory',1000,'person','trip'
from public.package_price_rules where revision_id=pg_temp.fixture_id(8,2);
update public.package_price_rules set travel_from=(statement_timestamp() at time zone 'Asia/Kathmandu')::date+10,
  travel_until=(statement_timestamp() at time zone 'Asia/Kathmandu')::date+12 where id=pg_temp.fixture_id(9,4);

-- Arithmetic and validation boundaries (100 minor units per NPR).
select is((private.calculate_group_price(123,'per_person',1,1,0,'[]')->>'total_minor')::bigint,123::bigint,'one traveler receives an exact integer total');
select is((private.calculate_group_price(1,'per_person',10000,365,364,'[]')->>'total_minor')::bigint,10000::bigint,'maximum traveler/day/night bounds are accepted');
select is((private.calculate_group_price(123,'per_group',10000,1,0,'[]')->>'total_minor')::bigint,123::bigint,'maximum group size does not multiply a group base');
select is((private.calculate_group_price(0,'per_group',1,1,0,'[{"classification":"mandatory","amount_minor":999,"unit":"person","frequency":"night"}]')->>'total_minor')::bigint,0::bigint,'zero-night trip charges zero night units');
select is((private.calculate_group_price(0,'per_group',10000,365,364,'[{"classification":"mandatory","amount_minor":1,"unit":"person","frequency":"day"}]')->>'total_minor')::bigint,3650000::bigint,'maximum person-day quantity remains exact');
select is((private.calculate_group_price(9000000000000000,'per_group',1,1,0,'[]')->>'total_minor')::bigint,9000000000000000::bigint,'exact money ceiling is accepted');
select is((private.calculate_group_price(900000000000,'per_person',10000,1,0,'[]')->>'total_minor')::bigint,9000000000000000::bigint,'multiplication reaches the exact ceiling without rounding');
select throws_ok($$select private.calculate_group_price(900000000001,'per_person',10000,1,0,'[]')$$,'22003',null,'multiplication exceeding the ceiling is rejected');
select is((private.calculate_group_price(0,'per_person',10,3,2,'[]')->>'total_minor')::bigint,0::bigint,'explicit zero base is quotable without inventing a coupon');
select is((private.calculate_group_price(80000,'per_person',5,3,2,'[{"classification":"mandatory","amount_minor":1000,"unit":"person","frequency":"trip"},{"classification":"mandatory","amount_minor":2000,"unit":"group","frequency":"day"},{"classification":"mandatory","amount_minor":3000,"unit":"group","frequency":"night"}]')->>'total_minor')::bigint,417000::bigint,'discounted base leaves person-trip, group-day and group-night fees intact');
select is((private.calculate_group_price(80000,'per_person',5,3,2,'[{"classification":"mandatory","amount_minor":100,"unit":"person","frequency":"day"},{"classification":"mandatory","amount_minor":200,"unit":"person","frequency":"night"}]')->>'total_minor')::bigint,403500::bigint,'discounted base leaves person-day and person-night fees intact');
select is(private.calculate_group_price(80000,'per_person',5,3,2,'[{"classification":"mandatory","amount_minor":null,"unit":"group","frequency":"trip"}]')->>'complete','false','discounted base does not hide an unknown required fee');
select is((private.calculate_group_price(80000,'per_person',5,3,2,'[{"classification":"included","amount_minor":null,"unit":"person","frequency":"day"},{"classification":"optional","amount_minor":9000000000000000,"unit":"group","frequency":"trip"}]')->>'total_minor')::bigint,400000::bigint,'included and optional charges are not added to discounted required total');
select throws_ok($$select private.calculate_group_price(9000000000000000,'per_group',1,1,0,'[{"classification":"mandatory","amount_minor":1,"unit":"group","frequency":"trip"}]')$$,'22003',null,'one minor unit above money ceiling is rejected');
select throws_ok($$select private.calculate_group_price(1,'per_person',10001,1,0,'[]')$$,'22023',null,'one above maximum traveler count is rejected');
select throws_ok($$select private.calculate_group_price(1,'per_person',null,1,0,'[]')$$,'22023',null,'unknown traveler count is rejected');
select throws_ok($$select private.calculate_group_price(1,'per_person',1,366,0,'[]')$$,'22023',null,'one above maximum duration is rejected');
select throws_ok($$select private.calculate_group_price(1,'per_person',1,3,3,'[]')$$,'22023',null,'nights cannot equal trip days');
select throws_ok($$select private.calculate_group_price(1,'per_person',1,3,-1,'[]')$$,'22023',null,'negative nights are rejected');
select throws_ok($$select private.calculate_group_price(-1,'per_group',1,1,0,'[]')$$,'22023',null,'negative base cannot encode a discount');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,'[{"classification":"mandatory","amount_minor":-1,"unit":"group","frequency":"trip"}]')$$,'22023',null,'negative mandatory fee cannot encode a discount');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,'[{"classification":"mandatory","amount_minor":0.5,"unit":"group","frequency":"trip"}]')$$,'22023',null,'fractional minor units cannot introduce rounding errors');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,'[{"classification":"discount","amount_minor":10,"unit":"group","frequency":"trip"}]')$$,'22023',null,'unsupported fixed discount classification fails explicitly');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,'[{"classification":"percentage_discount","percent":10}]')$$,'22023',null,'unsupported percentage discount fails explicitly');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,'[{"classification":"percentage_discount","percent":100}]')$$,'22023',null,'a 100 percent coupon is still unsupported');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,'[{"classification":"discount","amount_minor":1},{"classification":"discount","amount_minor":1}]')$$,'22023',null,'stacked discount components cannot silently reduce totals');
select throws_ok($$select private.calculate_group_price(null,'per_group',1,1,0,'[]')$$,'22023',null,'unknown base is never inferred to be free');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,null)$$,'22023',null,'missing component collection is rejected');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,'[{}]')$$,'22023',null,'missing component classification is rejected');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,'["discount"]')$$,'22023',null,'non-object component is rejected');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,'{}')$$,'22023',null,'components must be an array');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,'[{"classification":"mandatory","amount_minor":1,"unit":"room","frequency":"trip"}]')$$,'22023',null,'unsupported occupancy fee unit is rejected');
select throws_ok($$select private.calculate_group_price(1,'per_group',1,1,0,'[{"classification":"mandatory","amount_minor":1,"unit":"group","frequency":"hour"}]')$$,'22023',null,'unsupported fee frequency is rejected');
select throws_ok($$insert into public.package_price_components(price_rule_id,revision_id,agency_id,label,classification,amount_minor,unit,frequency) values(pg_temp.fixture_id(9,3),pg_temp.fixture_id(8,3),pg_temp.fixture_id(2,1),'TEST negative fee','mandatory',-1,'group','trip')$$,'23514',null,'database rejects stored negative fee');
select throws_ok($$insert into public.package_price_components(price_rule_id,revision_id,agency_id,label,classification,amount_minor,unit,frequency) values(pg_temp.fixture_id(9,3),pg_temp.fixture_id(8,3),pg_temp.fixture_id(2,1),'TEST coupon','discount',1,'group','trip')$$,'23514',null,'database rejects stored discount components');
select throws_ok($$update public.package_price_rules set base_minor=-1 where id=pg_temp.fixture_id(9,3)$$,'23514',null,'database rejects stored negative base');
select throws_ok($$insert into public.package_price_rules(revision_id,agency_id,basis,base_minor,min_travelers,max_travelers,sales_from,sales_until,source_note) values(pg_temp.fixture_id(8,1),pg_temp.fixture_id(2,1),'per_person',1,4,5,statement_timestamp(),statement_timestamp()+interval '1 day','SYNTHETIC overlap')$$,'23P01',null,'a discount tier cannot overlap at traveler boundaries');

-- Moderation reason boundaries: exercise real authorized RPCs and audit writes.
select pg_temp.actor(1);
set local role authenticated;
select throws_ok($$select public.admin_review_agency(pg_temp.fixture_id(3,1),true,repeat('x',2001),pg_temp.fixture_id(10,1))$$,'23514',null,'agency review rejects 2001 characters atomically');
select is((select status from public.agency_verifications where id=pg_temp.fixture_id(3,1)),'pending','failed long review leaves verification pending');
select is((select count(*)::integer from public.agency_approval_records),0,'failed long review leaves no approval record');
select throws_ok($$select public.admin_review_agency(pg_temp.fixture_id(3,1),true,'   ',gen_random_uuid())$$,'23514',null,'blank agency review reason is rejected');
select lives_ok($$select public.admin_review_agency(pg_temp.fixture_id(3,1),true,repeat('क',2000),pg_temp.fixture_id(10,2))$$,'agency review accepts exactly 2000 Unicode characters');
select is((select char_length(reason) from public.audit_logs where action='agency_reviewed' and agency_id=pg_temp.fixture_id(2,1)),2000,'agency audit retains complete 2000-character reason');
select is((select target_id from public.audit_logs where action='agency_reviewed' and agency_id=pg_temp.fixture_id(2,1)),pg_temp.fixture_id(3,1),'agency audit target identifies the reviewed verification');
select lives_ok($$select public.admin_review_agency(pg_temp.fixture_id(3,2),true,repeat('x',1001),pg_temp.fixture_id(10,3))$$,'agency review accepts formerly failing 1001-character reason');
select is((select char_length(reason) from public.audit_logs where action='agency_reviewed' and agency_id=pg_temp.fixture_id(2,2)),1001,'audit does not truncate 1001-character reason');
select lives_ok($$select public.admin_set_agency_state(pg_temp.fixture_id(2,2),true,' '||repeat('x',1998)||' ',gen_random_uuid())$$,'agency state accepts 2000 stored characters including spaces');
select is((select reason from public.audit_logs where action='agency_state_changed' and agency_id=pg_temp.fixture_id(2,2)),' '||repeat('x',1998)||' ','audit preserves leading and trailing spaces without truncation');
select throws_ok($$select public.admin_set_agency_state(pg_temp.fixture_id(2,2),false,' '||repeat('x',1999)||' ',gen_random_uuid())$$,'23514',null,'agency state rejects 2001 stored characters even with 1999 trimmed characters');
select is((select operational_status from public.agencies where id=pg_temp.fixture_id(2,2)),'suspended','failed oversized state reason leaves agency state unchanged');
select public.admin_set_agency_state(pg_temp.fixture_id(2,2),false,'SYNTHETIC restore',gen_random_uuid());
select set_config('test.boundary_plan',public.admin_create_plan_version('synthetic-boundary-pilot','SYNTHETIC TEST PILOT','free_pilot',0,true,100,'none',false,0,pg_temp.fixture_id(10,4))::text,true);
select set_config('test.boundary_subscription',public.admin_assign_subscription(pg_temp.fixture_id(2,1),current_setting('test.boundary_plan')::uuid,statement_timestamp()-interval '1 day',statement_timestamp()+interval '365 days','SYNTHETIC ONLY',pg_temp.fixture_id(10,5))::text,true);
select public.admin_assign_subscription(pg_temp.fixture_id(2,2),current_setting('test.boundary_plan')::uuid,statement_timestamp()-interval '1 day',statement_timestamp()+interval '365 days','SYNTHETIC ONLY',pg_temp.fixture_id(10,6));
reset role;

select pg_temp.actor(2);
set local role authenticated;
select is((select count(*)::integer from public.package_revisions where agency_id=pg_temp.fixture_id(2,2)),0,'agency A cannot read B revisions');
with changed as (update public.package_revisions set title='SYNTHETIC unauthorized edit' where id=pg_temp.fixture_id(8,2) returning id)
select is((select count(*)::integer from changed),0,'agency A cannot update agency B draft');
select throws_ok($$select * from private.operation_requests$$,'42501',null,'agency cannot read private idempotency records');
select lives_ok($$select public.submit_package_revision(pg_temp.fixture_id(8,1),pg_temp.fixture_id(10,7))$$,'owner submits tier discount for moderation');
select throws_ok($$insert into public.package_price_components(price_rule_id,revision_id,agency_id,label,classification,amount_minor,unit,frequency) values(pg_temp.fixture_id(9,1),pg_temp.fixture_id(8,1),pg_temp.fixture_id(2,1),'TEST pending change','mandatory',1,'group','trip')$$,'42501',null,'pending tier prices cannot be changed');
with changed as (update public.package_revisions set title='unreviewed pending change' where id=pg_temp.fixture_id(8,1) returning id)
select is((select count(*)::integer from changed),0,'pending revision cannot be edited directly');
select throws_ok($$select public.publish_package(pg_temp.fixture_id(7,1),pg_temp.fixture_id(8,1),gen_random_uuid())$$,'23514',null,'pending revision cannot be published');
select public.submit_package_revision(pg_temp.fixture_id(8,3),pg_temp.fixture_id(10,8));
select public.submit_package_revision(pg_temp.fixture_id(8,4),pg_temp.fixture_id(10,9));
select pg_temp.actor(3);
select is((select count(*)::integer from public.package_revisions where agency_id=pg_temp.fixture_id(2,1)),0,'agency B cannot read A revisions');
select ok(not exists(select 1 from public.user_roles where user_id=pg_temp.fixture_id(1,3) and role='admin'),'signup metadata cannot grant admin');
select throws_ok($$select public.admin_set_role(pg_temp.fixture_id(1,3),'admin',true,'TEST escalation',gen_random_uuid())$$,'42501',null,'agency B cannot elevate role through admin RPC');
select throws_ok($$select public.create_package(pg_temp.fixture_id(2,1),'foreign-write',gen_random_uuid())$$,'42501',null,'agency B cannot create A package');
select public.submit_package_revision(pg_temp.fixture_id(8,2),pg_temp.fixture_id(10,10));
reset role;

select pg_temp.actor(1);
set local role authenticated;
select throws_ok($$select public.admin_review_package(pg_temp.fixture_id(8,1),true,repeat('x',2001),pg_temp.fixture_id(10,11))$$,'23514',null,'package review rejects 2001 characters atomically');
select is((select status from public.package_revisions where id=pg_temp.fixture_id(8,1)),'pending_review','failed package review preserves pending state');
select is((select count(*)::integer from public.package_review_records where revision_id=pg_temp.fixture_id(8,1)),0,'failed package review has no review record');
select throws_ok($$select public.admin_review_package(pg_temp.fixture_id(8,1),true,' '||repeat('x',1999)||' ',gen_random_uuid())$$,'23514',null,'package review counts stored spaces in the 2000-character limit');
select throws_ok($$select public.admin_review_package(pg_temp.fixture_id(8,1),true,'   ',gen_random_uuid())$$,'23514',null,'blank package review reason is rejected');
select lives_ok($$select public.admin_review_package(pg_temp.fixture_id(8,1),true,repeat('x',2000),pg_temp.fixture_id(10,12))$$,'package review accepts exactly 2000 characters');
select is((select char_length(reason) from public.audit_logs where action='revision_reviewed' and target_id=pg_temp.fixture_id(8,1)),2000,'package audit retains full reason');
select lives_ok($$select public.admin_review_package(pg_temp.fixture_id(8,2),true,repeat('x',1001),pg_temp.fixture_id(10,13))$$,'package review accepts 1001-character reason');
select public.admin_review_package(pg_temp.fixture_id(8,3),false,'SYNTHETIC rejection',pg_temp.fixture_id(10,14));
select public.admin_review_package(pg_temp.fixture_id(8,4),true,'SYNTHETIC review',pg_temp.fixture_id(10,15));
reset role;
select pg_temp.actor(2);
set local role authenticated;
select throws_ok($$select public.publish_package(pg_temp.fixture_id(7,3),pg_temp.fixture_id(8,3),gen_random_uuid())$$,'23514',null,'rejected revision cannot be published');
select lives_ok($$select public.reopen_package_revision(pg_temp.fixture_id(8,3),pg_temp.fixture_id(10,16))$$,'owner can reopen rejected revision');
select is((select status from public.package_revisions where id=pg_temp.fixture_id(8,3)),'draft','reopened revision is draft');
with changed as (update public.package_revisions set description='SYNTHETIC revised description' where id=pg_temp.fixture_id(8,3) returning id)
select is((select count(*)::integer from changed),1,'reopened draft can be edited');
select public.submit_package_revision(pg_temp.fixture_id(8,3),pg_temp.fixture_id(10,17));
reset role;
select pg_temp.actor(1);
set local role authenticated;
select public.admin_review_package(pg_temp.fixture_id(8,3),true,'SYNTHETIC re-review',pg_temp.fixture_id(10,18));
select public.publish_package(pg_temp.fixture_id(7,1),pg_temp.fixture_id(8,1),pg_temp.fixture_id(10,19));
select public.publish_package(pg_temp.fixture_id(7,2),pg_temp.fixture_id(8,2),pg_temp.fixture_id(10,20));
select public.publish_package(pg_temp.fixture_id(7,3),pg_temp.fixture_id(8,3),pg_temp.fixture_id(10,21));
select public.publish_package(pg_temp.fixture_id(7,4),pg_temp.fixture_id(8,4),pg_temp.fixture_id(10,22));
reset role;

-- Public tier quotes and inclusive travel dates.
set local role anon;
select is((public.quote_package(pg_temp.fixture_id(7,1),1)->>'total_minor')::bigint,105000::bigint,'minimum traveler uses regular rate plus one group fee');
select is((public.quote_package(pg_temp.fixture_id(7,1),4)->>'total_minor')::bigint,405000::bigint,'last traveler count in regular tier uses regular rate');
select is((public.quote_package(pg_temp.fixture_id(7,1),5)->>'total_minor')::bigint,405000::bigint,'first discounted group count uses lower rate and mandatory fee');
select is((public.quote_package(pg_temp.fixture_id(7,1),10)->>'total_minor')::bigint,805000::bigint,'maximum tier count uses discounted rate without compounding');
select is(public.quote_package(pg_temp.fixture_id(7,1),5)->>'price_rule_id',pg_temp.fixture_id(9,101)::text,'discounted boundary selects exactly the approved tier');
select is((public.quote_package(pg_temp.fixture_id(7,2),4)->>'total_minor')::bigint,104000::bigint,'last regular per-group tier charges base once plus four person fees');
select is((public.quote_package(pg_temp.fixture_id(7,2),5)->>'total_minor')::bigint,95000::bigint,'first discounted per-group tier charges base once plus five full person fees');
select is((public.quote_package(pg_temp.fixture_id(7,2),10)->>'total_minor')::bigint,100000::bigint,'maximum discounted group charges base once plus ten full person fees');
select is(public.quote_package(pg_temp.fixture_id(7,2),5)->>'price_rule_id',pg_temp.fixture_id(9,102)::text,'per-group discount selects its own approved rule');
select is(public.quote_package(pg_temp.fixture_id(7,1),5)->>'currency','NPR','tier discount preserves the explicit NPR currency');
select is(public.quote_package(pg_temp.fixture_id(7,1),11)->>'reason','group_size_mismatch','above maximum group is explicitly unquotable');
select throws_ok($$select public.quote_package(pg_temp.fixture_id(7,1),0)$$,'22023',null,'public quote rejects zero travelers');
select throws_ok($$select public.quote_package(pg_temp.fixture_id(7,1),10001)$$,'22023',null,'public quote rejects more than platform maximum');
select throws_ok($$select public.quote_package(pg_temp.fixture_id(7,1),1,(statement_timestamp() at time zone 'Asia/Kathmandu')::date-1)$$,'22023',null,'past Nepal travel date is rejected');
select throws_ok($$select public.quote_package(pg_temp.fixture_id(7,1),1,'infinity'::date)$$,'22023',null,'infinite travel date is rejected');
select is(public.quote_package(pg_temp.fixture_id(7,4),1,(statement_timestamp() at time zone 'Asia/Kathmandu')::date+10)->>'complete','true','trip fits exact inclusive first and last travel dates');
select is(public.quote_package(pg_temp.fixture_id(7,4),1,(statement_timestamp() at time zone 'Asia/Kathmandu')::date+9)->>'reason','no_applicable_price','trip starting before travel window is unquotable');
select is(public.quote_package(pg_temp.fixture_id(7,4),1,(statement_timestamp() at time zone 'Asia/Kathmandu')::date+11)->>'reason','no_applicable_price','trip ending after travel window is unquotable');
select is(public.quote_package(pg_temp.fixture_id(7,4),1)->>'reason','no_applicable_price','dated-only price is not invented for undated request');
select throws_ok($$select * from public.package_price_rules$$,'42501',null,'anonymous cannot bypass quote projection for raw prices');
select throws_ok($$select * from public.agency_verifications$$,'42501',null,'anonymous cannot read verification evidence');
select throws_ok($$select public.admin_set_role(pg_temp.fixture_id(1,3),'admin',true,'SYNTHETIC escalation',gen_random_uuid())$$,'42501',null,'anonymous cannot execute role administration');
reset role;

-- Mutate fixtures and evaluate within ONE outer statement. statement_timestamp()
-- stays identical inside each helper, so exact endpoints are tested without sleeps.
create function pg_temp.availability_case(p_status text,p_remaining integer,p_age interval) returns text
language plpgsql as $fn$
begin
  delete from public.package_availability where revision_id=pg_temp.fixture_id(8,1);
  insert into public.package_availability(revision_id,agency_id,kind,starts_on,ends_on,status,remaining_travelers,confirmed_at,confirmed_by,source_note)
  values(pg_temp.fixture_id(8,1),pg_temp.fixture_id(2,1),'fixed_departure',
    (statement_timestamp() at time zone 'Asia/Kathmandu')::date+10,(statement_timestamp() at time zone 'Asia/Kathmandu')::date+12,
    p_status,p_remaining,statement_timestamp()-p_age,pg_temp.fixture_id(1,2),'SYNTHETIC AVAILABILITY');
  return public.quote_package(pg_temp.fixture_id(7,1),5,(statement_timestamp() at time zone 'Asia/Kathmandu')::date+10)->>'availability_status';
end;
$fn$;
select is(pg_temp.availability_case('open',5,interval '0'),'agency_confirmed','capacity equal to traveler count is sufficient');
select is(pg_temp.availability_case('open',4,interval '0'),'requires_confirmation','one seat short cannot claim availability');
select is(pg_temp.availability_case('open',null,interval '0'),'requires_confirmation','unknown remaining capacity is not confirmation');
select is(pg_temp.availability_case('sold_out',0,interval '0'),'requires_confirmation','sold-out date cannot claim availability');
select is(pg_temp.availability_case('closed',10,interval '0'),'requires_confirmation','closed date cannot claim availability');
select is(pg_temp.availability_case('on_request',10,interval '0'),'requires_confirmation','on-request date cannot claim availability');
select is(pg_temp.availability_case('open',5,interval '30 days'),'requires_confirmation','confirmation expires at exactly 30 days');
select is(pg_temp.availability_case('open',5,interval '30 days'-interval '1 microsecond'),'agency_confirmed','confirmation remains valid just before expiry');
select is(pg_temp.availability_case('open',5,interval '-1 microsecond'),'requires_confirmation','future confirmation cannot claim availability');

create function pg_temp.reconfirmation_case(p_age interval) returns boolean language plpgsql as $fn$
begin
  update public.packages set last_reconfirmed_at=statement_timestamp()-p_age where id=pg_temp.fixture_id(7,1);
  return private.package_visible(pg_temp.fixture_id(7,1));
end;
$fn$;
select ok(not pg_temp.reconfirmation_case(interval '30 days'),'package reconfirmation expires at exactly 30 days');
select ok(pg_temp.reconfirmation_case(interval '30 days'-interval '1 microsecond'),'package remains eligible just before reconfirmation expiry');
select ok(not pg_temp.reconfirmation_case(interval '-1 microsecond'),'future package reconfirmation is ineligible');
select ok(pg_temp.reconfirmation_case(interval '0'),'current package reconfirmation is eligible');

create function pg_temp.subscription_case(p_from interval,p_until interval) returns boolean language plpgsql as $fn$
begin
  update public.agency_subscriptions set starts_at=statement_timestamp()+p_from,ends_at=statement_timestamp()+p_until
    where id=current_setting('test.boundary_subscription')::uuid;
  return private.package_visible(pg_temp.fixture_id(7,1));
end;
$fn$;
select ok(pg_temp.subscription_case(interval '0',interval '1 day'),'subscription is effective at exact start');
select ok(not pg_temp.subscription_case(interval '1 microsecond',interval '1 day'),'subscription is ineligible just before start');
select ok(not pg_temp.subscription_case(interval '-1 day',interval '0'),'subscription is ineligible at exact exclusive end');
select ok(pg_temp.subscription_case(interval '-1 day',interval '1 microsecond'),'subscription is eligible just before exclusive end');
select ok(pg_temp.subscription_case(interval '-1 day',interval '365 days'),'restore synthetic subscription for remaining tests');

create sequence pg_temp.sales_case_sequence start 200;
create function pg_temp.sales_case(p_from interval,p_until interval) returns text language plpgsql as $fn$
declare v_n integer:=nextval('pg_temp.sales_case_sequence'); v_revision uuid;
begin
  v_revision:=pg_temp.offer(v_n,1,'per_person',20);
  update public.package_price_rules set max_travelers=10,sales_from=statement_timestamp()+p_from,sales_until=statement_timestamp()+p_until
    where id=pg_temp.fixture_id(9,v_n);
  -- Separate current tier keeps the package eligible when the requested tier is
  -- not yet on sale or has expired. It must never supply the wrong group's price.
  insert into public.package_price_rules(revision_id,agency_id,basis,base_minor,min_travelers,max_travelers,sales_from,sales_until,source_note)
  values(v_revision,pg_temp.fixture_id(2,1),'per_person',1,11,20,statement_timestamp()-interval '1 day',statement_timestamp()+interval '1 day','SYNTHETIC OTHER TIER');
  perform pg_temp.actor(1);
  perform public.submit_package_revision(v_revision,gen_random_uuid());
  perform public.admin_review_package(v_revision,true,'SYNTHETIC sales boundary',gen_random_uuid());
  perform public.publish_package(pg_temp.fixture_id(7,v_n),v_revision,gen_random_uuid());
  return coalesce(public.quote_package(pg_temp.fixture_id(7,v_n),5)->>'reason','quoted');
end;
$fn$;
select is(pg_temp.sales_case(interval '0',interval '1 day'),'quoted','sales start is inclusive at exact instant');
select is(pg_temp.sales_case(interval '1 microsecond',interval '1 day'),'no_applicable_price','one microsecond before sales start is unquotable');
select is(pg_temp.sales_case(interval '-1 day',interval '0'),'no_applicable_price','sales end is exclusive at exact instant');
select is(pg_temp.sales_case(interval '-1 day',interval '1 microsecond'),'quoted','one microsecond before sales end is quotable');

-- Full RLS coverage and private calculation boundaries remain intact.
select is((select count(*)::integer from pg_catalog.pg_class c join pg_catalog.pg_namespace n on n.oid=c.relnamespace
  where n.nspname in ('public','private') and c.relkind='r' and not c.relrowsecurity),0,'every application table has RLS enabled');
select ok(not has_table_privilege('anon','public.agency_memberships','SELECT'),'anonymous has no membership read grant');
select ok(not has_table_privilege('authenticated','public.agency_memberships','UPDATE'),'authenticated has no membership mutation grant');
select ok(not has_function_privilege('anon','private.calculate_group_price(bigint,text,integer,integer,integer,jsonb)','EXECUTE'),'anonymous cannot invoke private calculator');
select ok(not has_function_privilege('authenticated','private.effective_plan(uuid)','EXECUTE'),'tenant cannot invoke private entitlement function');
-- A trusted fixture owner simulates revocation; stale agency/JWT roles cannot
-- substitute for current database membership. Restore only the synthetic row.
update public.agency_memberships set status='revoked' where agency_id=pg_temp.fixture_id(2,1);
select pg_temp.actor(2);
set local role authenticated;
select is((select count(*)::integer from public.agencies),0,'revoked owner cannot read its former agency');
select is((select count(*)::integer from public.package_revisions),0,'revoked owner cannot read former agency revisions');
select throws_ok($$select public.create_package(pg_temp.fixture_id(2,1),'revoked-owner-write',gen_random_uuid())$$,'42501',null,'revoked owner cannot use tenant RPC despite retaining agency role');
reset role;
update public.agency_memberships set status='active' where agency_id=pg_temp.fixture_id(2,1);
select * from finish();
rollback;
