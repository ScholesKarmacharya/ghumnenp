# Ghumne RLS inspection — hosted application pending

Reviewed 2026-10-20: all **54 policies, 46 tables (45 public + one private)** and the public/private RPC authorization paths across migrations 001–009. This is source inspection and static-contract evidence. **No migration, pgTAP assertion or deployed RLS check has executed. Database security is not verified.**

## Complete policy inventory

Every table enables RLS and revokes inherited/default table grants from PUBLIC, anon, authenticated and service_role before explicit grants. Every policy targets authenticated. Policies are permissive, so policies for the same command combine with OR; the overlapping package read/draft policies were reviewed with that behavior in mind.

| Tables                       | Policies                                                            | Effective source-level boundary                                                                                |
| ---------------------------- | ------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| profiles                     | profile_read, profile_update                                        | Own/admin reads; own display_name/avatar_url updates only; no API insert/delete or identity update             |
| user_roles                   | role_read                                                           | Own/admin reads; no API role writes                                                                            |
| marketplace_settings         | settings_admin                                                      | Admin predicate in USING and WITH CHECK; SELECT/UPDATE grants only                                             |
| retention_policies           | retention_admin                                                     | Same admin boundary; configuration does not run deletion                                                       |
| audit_logs                   | audit_admin_read                                                    | Admin reads; no API writes; immutable trigger                                                                  |
| agencies                     | agency_read                                                         | Current member/admin reads; approvals/status RPC-only                                                          |
| agency_memberships           | membership_read                                                     | Current member/admin reads; ownership/status RPC/operator-only                                                 |
| agency_verifications         | verification_read                                                   | Current member/admin reads of private evidence metadata; submission/review RPC-only                            |
| agency_approval_records      | approval_read                                                       | Current member/admin reads; append-only RPC writes                                                             |
| subscription_plans           | plan_read                                                           | Intentionally shared authenticated read; admin lifecycle RPC writes                                            |
| subscription_plan_versions   | plan_version_read                                                   | Intentionally shared authenticated read; immutable version terms; admin creation RPC                           |
| agency_subscriptions         | subscription_read                                                   | Current member/admin reads; activation/status RPC-only                                                         |
| subscription_change_requests | subscription_request_read                                           | Current member/admin reads; requests do not activate subscriptions                                             |
| locations                    | locations_admin                                                     | Admin USING/WITH CHECK; SELECT/INSERT/UPDATE only                                                              |
| destinations                 | destinations_admin                                                  | Same admin-only grants; curated public projection omits unpublished data                                       |
| destination_media            | destination_media_admin                                             | Admin-only knowledge/media maintenance                                                                         |
| interests                    | interests_admin                                                     | Admin-only maintenance                                                                                         |
| destination_interests        | destination_interests_admin                                         | Admin-only associations                                                                                        |
| destination_seasons          | destination_seasons_admin                                           | Admin-only seasonal knowledge                                                                                  |
| attractions                  | attractions_admin                                                   | Admin-only maintenance                                                                                         |
| activities                   | activities_admin                                                    | Admin-only maintenance                                                                                         |
| transport_routes             | transport_routes_admin                                              | Admin-only maintenance                                                                                         |
| destination_costs            | destination_costs_admin                                             | Admin-only maintenance                                                                                         |
| packages                     | packages_read                                                       | Current member/admin reads; state/published/reconfirmed pointers RPC-only                                      |
| package_revisions            | package_revisions_read, revision_insert, revision_edit              | Member/admin reads; owned draft insert/edit with restricted columns; no direct status/reviewer/tenant mutation |
| package_destinations         | package_destinations_read, package_destinations_draft_write         | Member/admin reads; current member and matching draft for insert/update/delete                                 |
| package_origins              | package_origins_read, package_origins_draft_write                   | Same owned draft boundary                                                                                      |
| package_interests            | package_interests_read, package_interests_draft_write               | Same owned draft boundary                                                                                      |
| package_itinerary_days       | package_itinerary_days_read, package_itinerary_days_draft_write     | Same owned draft boundary                                                                                      |
| package_itinerary_items      | package_itinerary_items_read, package_itinerary_items_draft_write   | Same owned draft boundary plus day/revision/agency FK                                                          |
| package_price_rules          | package_price_rules_read, package_price_rules_draft_write           | Same owned draft boundary plus nonoverlapping tier/date/sales scopes                                           |
| package_price_components     | package_price_components_read, package_price_components_draft_write | Same owned draft boundary plus rule/revision/agency FK                                                         |
| package_availability         | package_availability_read                                           | Current member/admin reads; tenant-checking capacity/confirmation RPC only                                     |
| package_media                | package_media_read, package_media_draft_write                       | Same owned draft boundary; no API path to evidence documents                                                   |
| package_review_records       | package_review_records_read                                         | Current member/admin reads; admin-only append-only review RPC                                                  |
| trips                        | trips_owner                                                         | Own CRUD only, USING and WITH CHECK bind auth.uid()                                                            |
| trip_days                    | trip_days_owner                                                     | Own CRUD; composite trip/owner FK; duration guard                                                              |
| trip_items                   | trip_items_owner                                                    | Own CRUD; composite day/trip/owner FK                                                                          |
| favorites                    | favorites_owner                                                     | Own CRUD only                                                                                                  |
| trip_shares                  | share_owner_read                                                    | Owner reads; controlled owner RPC creation/revocation                                                          |
| trip_package_comparisons     | comparison_owner_read                                               | Owner reads; controlled RPC derives current quote/snapshot                                                     |
| inquiries                    | inquiry_read                                                        | Owning traveler, current agency member or admin reads; backend-only creation; agency/admin status RPC          |
| inquiry_rate_limits          | No policy                                                           | No API table grants: default deny even to authenticated; trusted definer path only                             |
| featured_placements          | placement_read                                                      | Current member/admin reads; admin-only creation/pause; eligibility-bound public serving                        |
| marketplace_events           | No policy                                                           | No API table grants; backend/definer writes only                                                               |
| private.operation_requests   | No policy                                                           | No API table grants; actor/action/fingerprint-checked internal idempotency ledger                              |

## Agency isolation and escalation findings

Membership requires both an active database membership and the database-backed agency role for auth.uid(). Signup metadata is never trusted for roles/tenant IDs. register_agency creates a new pending agency and its caller's membership; it cannot approve it, grant admin or activate an entitlement. ensure_profile grants only traveler. admin_set_role checks an existing administrator, serializes role administration, rechecks after waiting, protects the final administrator and prevents removing agency role while active ownership exists.

Tenant foreign keys bind package/revision/agency, price-rule/revision/agency, itinerary/day ownership, inquiry snapshots and placements. Revision triggers reject reparenting and lock the revision against non-draft edits. RLS USING/WITH CHECK and column grants jointly constrain direct writes. The read policy OR draft policy does not grant write access through the SELECT-only read policy. A revoked membership no longer satisfies helpers even with a stale agency JWT/role.

Trusted admin reads across agencies are intentional. Shared plan/version authenticated reads are intentional; they contain commercial definitions, not tenant contact/evidence data. Travelers do not gain agency reads through their traveler role. Admin access to traveler trips is not granted by the owner policies. Inquiry access intentionally includes its owning traveler and agency; other agencies receive neither a table row nor a successful mutation RPC.

## Unauthorized access and definer review

Anon has no raw application table grant. Its execute allowlist is quote_package, catalog_destinations, catalog_packages, package_detail, sponsored_packages and shared_trip. Public catalog/quote projections check current eligibility and select explicit fields. Share reads require the hashed bearer token, unlisted visibility, nonrevocation and nonexpiry; private traveler identity/notes are omitted. No arbitrary SQL execution or user-controlled search path exists.

All created functions fix search_path to the empty string and revoke implicit PUBLIC/API-role execution before selective grants. Private authorization/quote/workflow helpers are not general public RPCs. submit_inquiry is executable only by service_role and derives tenant/revision/quote itself; it defaults disabled pending consent/retention/server controls. service_role receives no direct application table grant here, but BYPASSRLS and trusted definer ownership must still be reviewed in the actual hosted catalog.

Security-definer functions intentionally execute as their trusted owner, bypassing normal RLS. Their explicit actor checks are part of the security boundary; RLS alone is insufficient. Fixed paths/qualified relations prevent ordinary path replacement. Keep private outside the hosted exposed API schemas. The migration owner, inherited role memberships, hosted default privileges and any extra roles/objects cannot be verified from source.

Some RPCs look up an object before checking tenancy and can distinguish nonexistent IDs from unauthorized IDs through different errors. No private row fields are returned on those rejection paths, but application error mapping and API probes must avoid exposing unnecessary existence information. Concurrent role/membership revocation and transition races remain a separate-session test requirement; static locks are not proof of race safety.

## Prepared evidence and outstanding execution

The 206 assertions include both agency identities, cross-agency draft reads/writes/RPC rejection, self-role/direct-state denial, spoofed signup metadata, revoked membership with retained role, private helper/ledger and anon restrictions, traveler/share/inquiry isolation and pricing/moderation/time boundaries. **All remain unrun.** The source suites use trusted synthetic fixtures then SET ROLE/JWT claims to exercise ordinary roles; their operator-level setup is not itself evidence of ordinary access being safe.

After approved application, record actual results for both files, inspect all hosted table/function owners and effective grants, verify private schema exposure, test two real API/Auth identities and anon/service boundaries, and run parallel-session moderation/quota/subscription/role-revocation checks plus query plans. Auth signup/session integration, Storage policies, inquiry server validation/rate controls and retention execution remain future gates. No production readiness or security certification is claimed.

## Other-project scope

The nine migration files contain no project selector/URL, connection switch, dblink/FDW/network call or billing action. All effects are local to the connected PostgreSQL database, including the Auth trigger. A wrong connection would still run the SQL there; use the pinned Ghumne reference, isolated one-file workdir, linked guard and reviewed history/dry run in [the hosted workflow](../SUPABASE_DEVELOPMENT_SETUP.md). No other project was accessed or changed.
