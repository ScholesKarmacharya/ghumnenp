# Ghumne database implementation review

Updated: 2026-10-20. Current scope: **hosted Supabase Cloud only; no Docker, WSL or Linux**. The owner confirms the dedicated Ghumne development project. The exact configured reference and keyed read-only Auth connectivity match; dashboard/catalog/history verification and CLI link remain pending. **No SQL migration or pgTAP assertion has executed. Database security is not runtime-verified.** No destructive database operation, deployment, other-project/Mount Kailash access or billing activation occurred. See [SUPABASE_DEVELOPMENT_SETUP.md](SUPABASE_DEVELOPMENT_SETUP.md) for the cloud workflow and exact first-migration approval boundary. Historical preparation entries below do not override this cloud-only instruction.

## 1. Completed TASK-015 verification

Existing feedback components and conventions were preserved: `LoadingState`/`Skeleton`, `EmptyState`, `ErrorState`, `SuccessMessage`, public loading/error, global error and not-found. No production UI rewrite was needed.

- Six unit tests verify named loading status/hidden skeletons, semantic heading choice, real recovery links, alert/status semantics, confidential error/digest handling, global document shell and the actual Next reset callback passed to recovery buttons.
- Six Edge/Playwright browser tests verify keyboard retry and focus, 44px controls, 320/390/768/1440px reflow at normal and doubled text size, reduced motion, no runtime errors, 404 recovery and axe accessibility. Axe reported zero violations on the tested preview main/404 surfaces.
- Mobile and desktop screenshots were inspected. Production smoke verification confirms `/ui-preview` returns 404 and the existing homepage remains HTTP 200 with one main/h1.
- The full quality gate passed: formatting, lint, strict TypeScript, SQL/procedure syntax checks, **84 unit tests across six files**, and production build. Production browser assertions passed separately. Automated accessibility checks do not substitute for later full-product assistive-technology testing.

## 2. Entity relationship summary

The draft contains 45 public tables plus one private idempotency ledger. The schema is explicit and normalized; actual application database types remain intentionally empty until approved application and generation.

| Domain                 | Main entities and relationships                                                                                                                                                         |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Identity               | `auth.users -> profiles -> user_roles`; trusted capabilities, never editable signup metadata                                                                                            |
| Agencies               | `agencies -> agency_memberships`, private verification submissions and immutable approval decisions                                                                                     |
| Commercial access      | `subscription_plans -> subscription_plan_versions -> agency_subscriptions`; agency change requests are separate from activation                                                         |
| Destination knowledge  | Locations, destinations/media, interests, seasons, attractions, activities, transport and unit-based costs                                                                              |
| Offers                 | `agencies -> packages -> package_revisions`; revisions own many destination/origin/interest associations, itinerary days/items, price rules/components, availability and review history |
| Traveler plans         | `profiles -> trips -> trip_days -> trip_items`, favorites, revocable hashed-token shares and package comparison snapshots                                                               |
| Marketplace operations | Package/revision/agency-consistent inquiries, abuse counters, sponsored placements, minimal events, audit and configurable retention/settings                                           |

One destination can have offers from many agencies. A package can visit many destinations. Composite foreign keys prevent attaching a foreign agency's revision, pricing, availability, itinerary, inquiry or placement to an owned parent. Referenced history uses restrictive deletion, not cascading loss of agency records.

## 3. Migration order

All files under `supabase/migrations` are numbered review drafts with explicit transaction boundaries. All nine names/order are preserved. Existing repairs in 001/006/007 are preserved; current edits align full stored reason limits in 002/004. No migration was added, removed or applied. Hosted linking/history/preflight and explicit first-file approval remain pending; production remains excluded.

| Order | File                                      | Content                                                                                                                           |
| ----- | ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| 001   | `202610200001_identity.sql`               | Profiles/roles, configuration/retention, audit, safe signup bootstrap and admin helpers                                           |
| 002   | `202610200002_agencies_subscriptions.sql` | Agency tenancy/verification/approval, plan versions, assignments and nonoverlapping subscription periods; btree_gist prerequisite |
| 003   | `202610200003_destinations.sql`           | Normalized Nepal destination knowledge and search/query indexes                                                                   |
| 004   | `202610200004_packages.sql`               | Offers/revisions, ordered itineraries, pricing scopes, availability, moderation and draft immutability boundaries                 |
| 005   | `202610200005_travelers_marketplace.sql`  | Owned saved plans/shares/comparisons, private inquiries, abuse counters, placements/events                                        |
| 006   | `202610200006_pricing_visibility.sql`     | Effective entitlement, public eligibility, group-price engine and quote contract                                                  |
| 007   | `202610200007_workflows.sql`              | Idempotent registration, review, manual subscriptions, publication/quota and reconfirmation                                       |
| 008   | `202610200008_catalog_operations.sql`     | Curated public catalog/quotes, availability, placement, backend-only inquiry, comparison and sharing workflows                    |
| 009   | `202610200009_integrity_controls.sql`     | Evidence/snapshot/itinerary checks, role administration, lifecycle controls and minimal audit triggers                            |

Only operational settings/retention categories are inserted by migrations. There are no real or demo agency/package seed listings. Synthetic fixtures exist exclusively in a guarded, rolled-back test script.

Inspection found the expected dependency order: 001 establishes identity/helpers; 002 adds tenancy, subscriptions and `btree_gist`; 003 supplies destination references; 004 adds revision/pricing/availability tables; 005 supplies traveler/inquiry/placement tables; 006 depends on those for quote/eligibility functions; 007 introduces the private operation ledger and transition RPCs; 008 uses that ledger for public/operational RPCs; 009 adds final constraints, lifecycle controls and triggers. No missing file dependency was identified by inspection. PostgreSQL catalog resolution has not been tested.

**Rollback and retry risks:** each file commits separately. Failure in 008, for example, leaves 001-007 committed. These are one-time migrations, not scripts to replay after a partial application; use migration history and inspect the failed transaction before a forward repair. Existing application object names deliberately fail rather than silently overwrite data. The bundle has no down/reset path. Initial ordinary indexes are appropriate for empty tables; future indexes on populated tables need separate locking/online-index review. Existing `btree_gist` outside `extensions`, an untrusted object owner or a different PostgreSQL/Auth catalog can prevent safe application. No extension relocation, schema reset or rollback was attempted.

Use the confirmed hosted development project only: verify target/version/namespace/extension and migration-owner permissions; obtain approval for the isolated first file, then separately for the remaining ordered files and synthetic tests; execute database tests; inspect query plans/concurrent workflows; generate actual types. No local database runtime is required or authorized. See [supabase/README.md](supabase/README.md).

## 4. RLS and authorization strategy

Every created table enables RLS and explicitly revokes inherited/default API grants. Anon has no raw table privileges: public reads use curated, bounded security-definer projections that enforce eligibility and omit private columns. Authenticated reads are owned traveler/tenant or admin-scoped; ordinary accounts cannot write roles, membership, agency approval, subscriptions, publication pointers, inquiry snapshots or placements directly.

Draft revision columns/children have narrowly scoped grants and RLS. A locking trigger rejects approved/pending content mutations and cross-revision reparenting. Sensitive transitions use fixed-search-path, explicitly granted RPCs that verify current database-backed admin/membership identity. Agency locks serialize subscription, suspension, quota, availability and publication operations. Request IDs, actor/action/fingerprint checks and result persistence handle retries without reusing keys for different payloads.

The backend-only inquiry RPC accepts no agency ID or submitted total. A future trusted endpoint must validate its inputs/identity/HMAC key before using the server-only service credential; no such privileged application client was introduced. Public functions cannot execute general SQL. Explicit grants and RLS work together; definer projection ownership must be reviewed carefully because owners can bypass RLS. These boundaries follow [Supabase's grants/RLS guidance](https://supabase.com/docs/guides/database/postgres/row-level-security) and [PostgreSQL function security guidance](https://www.postgresql.org/docs/17/sql-createfunction.html).

## 5. Package pricing calculation

Store NPR as integer minor units and calculate using numeric intermediates with a safe-integer ceiling of 9,000,000,000,000,000 minor units. Per-person base multiplies by traveler count; per-group base is charged once within its tier. Add mandatory fee quantities by person/group and trip/day/night. Included charges are not counted twice; optional extras do not enter the required total.

Unknown mandatory charges produce an incomplete quote, never zero. Unknown necessary exclusions prevent a whole-trip affordability claim. Nonoverlapping traveler/date/sales scopes select at most one rule; an out-of-tier/expired/unpriced request is explicitly unquotable. Availability is a separately labeled agency claim; unspecified dates remain unchecked. No quote reserves capacity.

SQL tests prepare cases for person/group totals, per-night units, included/optional handling, unknown charges, invalid inputs, overflow, group-size mismatch, confirmed versus unconfirmed dates and group quote snapshots. These runtime calculation tests are **prepared, not executed**; local syntax/security-contract checks are not a substitute. No application-side duplicate calculator or misleading live price is added.

**Discount scope confirmed by owner:** preserve V1 reviewed group tiers; reject negative fees and unsupported fixed/percentage discount inputs. Draft 006 now rejects malformed/unknown component classifications rather than silently ignoring them. No coupon/stacking/percentage-discount model was introduced. Draft 001 aligns audit reasons with existing 2,000-character review limits without truncation.

**Expanded prepared coverage:** the unchanged original 81 assertions are supplemented by **125** in `0002_pricing_boundaries.test.sql` (**206 total**). Existing probes cover discounted tiers, overlap, quantity/money/input/date/expiry limits, availability, Unicode reason limits, rollback, moderation/reopening and tenant/role boundaries. This run adds 28 checks for per-group tier discounts with full mandatory person fees, remaining fee quantity combinations, exact multiplication ceiling/overflow, explicit-zero/unknown prices, unsupported 100%/stacked discounts, stored spaces/blank reasons, state rollback, cross-agency draft edits, private ledger/anon access and revoked membership despite retained agency role. Exact-instant helpers evaluate in one outer statement without sleeps. These are syntax-checked, **not executed**. Real concurrent-session workflows, runtime grants/ownership, API identity/session integration and query plans remain outstanding.

## 6. Subscription and public eligibility rules

Public offers require approved active agency, effective active subscription/active plan with configured price and publishing entitlement, compliant published count, approved published revision, current pricing and reconfirmation of that exact revision within 30 days. End times are exclusive; status alone cannot keep an expired period eligible. A free pilot can satisfy entitlement without a paid plan or payment integration.

Monthly/annual assignment validates a Nepal calendar month/year; pilot dates are explicit admin input. Configurable immutable plan versions hold price, listing allowance, analytics level and promotion allowance. A downgrade cannot activate over the listing cap; pausing selected listings resolves it. Expiry/suspension hides eligibility and retains private agency data/inquiries.

Confirmed date matching additionally requires a covering departure/window, current agency confirmation and sufficient known remaining capacity. Sponsored serving adds current placement window/label and promotional entitlement/allowance checks; no promotional variable enters organic ordering. Future application caches must honor the same time boundaries and invalidations.

## 7. Remaining business decisions

[V1_BUSINESS_POLICIES.md](V1_BUSINESS_POLICIES.md) separates the owner's provisional rules, engineering assumptions and final choices. Open items: actual plan prices/limits/terms/pilot duration and any grace; evidence/review/appeal/owner-transfer rules; sponsorship allocation/commercial terms; retention durations/triggers/consent/deletion execution; child/room/discount scope; real launch inventory/media rights; target projects, first admin and deployment approval.

Inquiry collection defaults off and retention duration unset. No retention deletion job, Storage upload path, payment/billing integration or outbound message automation is installed.

## 8. Deployment/security risks and verification limits

1. **Database execution is unapplied and unverified.** SQL/PL/pgSQL parsing validates syntax, not catalog resolution, runtime policies, transaction races or execution plans. The original guarded 81 assertions remain unchanged; the separate boundary suite now has 125. All **206** remain unrun. Real hosted-database and parallel-session publication/subscription tests are release gates. See current cloud status below.
2. **No application auth integration yet.** Session proxy/route guards, server action validation/error mapping, privileged inquiry endpoint, Storage policies and cache invalidation remain assigned tasks. Prepared RPCs do not make a deployed marketplace. First-admin bootstrap must be an audited operator action for a verified existing auth user, never a seeded identity or self-grant route.
3. **Retention/abuse operations need completion before collecting contacts.** Configure durations/consent, implement and review retention processing and short-lived abuse/operation-key cleanup, then explicitly enable inquiry collection. Do not expose a service credential or accept a browser-provided agency, user identity, group price or abuse key.
4. **Dependency remediation is partial.** Compatible patches update Next.js/config to `16.3.8`, sharp to `0.35.5` and source-map-js to `1.2.2`. Full npm audit now reports **five high findings**, all from the development-only braces lint chain; production-only audit reports **zero vulnerabilities**. Braces has no patched release, and a framework minor update retains that chain. No force/downgrade audit fix or suppression was used. See [DEPENDENCY_SECURITY_REVIEW.md](DEPENDENCY_SECURITY_REVIEW.md) for all eight original findings, affected versions, dependency paths, advisory sources and the residual risk. A pre-existing dev server must restart to load the installed framework patch.
5. **Operator/configuration risks:** pre-existing schema names or a differently installed btree_gist extension need review; plan retirement can hide assigned offers; no scheduling job should be relied upon for expiry correctness; no real inventory or verification documents have been loaded. Public anonymous catalog/quote endpoints still need application-level traffic limits and performance testing.

TASK-015's preceding verification remains recorded in section 1. Current dependency regression results are recorded separately below; no migration command or database test runner was invoked.

**Current post-patch regression:** `npm.cmd run check` passed formatting, lint with zero warnings, strict types, all migration/pgTAP syntax checks, **84 unit/static-contract tests in six files** and the Next.js **16.3.8** production build. `npm.cmd run test:feedback:production` passed **1/1** with normal temporary-server cleanup. Top-level dependency-tree and whitespace checks passed. The six development accessibility/responsive browser scenarios remain earlier TASK-015 evidence; the pre-existing old-framework dev server was not restarted or used to certify the framework patch. No application UI/brand source changed.

## 9. Previous database preparation status — superseded by cloud status in section 12

| Requested check                    | Result in this run                                                                                                       |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Tool discovery                     | `Get-Command supabase`, `docker` and `psql`: none found on PATH                                                          |
| Known installations                | Docker CLI/Desktop under `C:\Program Files\Docker\Docker`, Supabase Chocolatey and current-user Scoop shim paths: absent |
| Local project configuration        | `supabase/config.toml` prepared and parsed as TOML; no CLI schema check/start or hosted config push executed             |
| Disposable database / connection   | Not created; no local or remote database connection attempted                                                            |
| Migration execution                | **0 of 9 executed**; no runtime migration result available                                                               |
| pgTAP                              | **0 passed, 0 failed, 178 not run** (81 preserved + 97 new); no TAP execution or certification                           |
| Tenant isolation / role escalation | Existing two-agency/two-traveler probes inspected; runtime checks blocked                                                |
| Pricing / availability             | Calculation and constraint text inspected; runtime correctness blocked, coverage gaps listed in section 5                |
| Subscriptions / moderation         | Eligibility and transition text inspected; runtime and concurrent-session checks blocked                                 |

No Supabase/database target environment values, CLI project link, branch target or real credential file are configured in this checkout. The offline unlinked check passes; test-copy preparation refuses to proceed without a reviewed development target and creates no CLI state. No production target is configured, but no remote project's development status is independently verified yet. Do not infer that a future reference is safe from its spelling; verify its identity/organization in the dashboard before confirmation.

The exact tool blocker remains absence of Supabase CLI and Docker (with no psql installed either). The current instruction independently stops before any database changes. No installer, stack start, remote substitute, login/link, migration apply/reset or billing operation was used. The setup guide supplies the two required public Next.js variables, optional CLI secrets, explicit profile/workdir/linked commands and guarded test preparation. Private values are not printed or stored in templates. Local configuration does not automatically configure hosted Auth/exposed schemas.

**RLS findings by inspection:** all 46 tables enable RLS and revoke default API access; private tenant/role helpers use database-backed identity, public reads are bounded projections, and privileged writes use explicit authorization and fixed function search paths. Composite tenant references and draft guards are present. This does not establish effective deployed grants, function ownership, PostgREST schema exposure, bidirectional identity isolation or resistance to concurrency races. Check those using actual authenticated/anon/service roles and separate sessions after local migration succeeds.

**Subscription findings by inspection:** effective-plan checks use an active assignment and active, configured plan at `starts_at <= now < ends_at`; public visibility additionally checks approval, active agency, publication/review, quota, current pricing and revision reconfirmation. Expiry removes public eligibility without deleting agency records. These rules are present in SQL, but neither visibility nor exact time-boundary enforcement has run in PostgreSQL.

**Reason-length repair:** unapplied draft 001 now allows `audit_logs.reason` up to 2,000 characters, consistent with review/approval records. Added real-RPC probes for formerly failing 1,001-character reasons, exactly 2,000 Unicode characters, 2,001-character rejection, retained full audit reasons and atomic failure. Narrower subscription-operation reason limits remain intentional. No database constraint was altered in a running database; success is still pending actual execution.

**Audit-reference repair:** draft 007's agency-review audit entry previously named `agency_verifications` but used the approval-record UUID. It now uses the reviewed verification UUID; an additional assertion verifies this reference. The approval RPC still returns its original approval-record ID, preserving its API contract.

**Final preparation verification:** after all repairs, `npm.cmd run check` passes formatting, lint with zero warnings, strict TypeScript, all SQL/PL/pgSQL/function-body/probe syntax checks, **109 unit/static-contract/target tests in seven files** and production build. TOML syntax/development settings, unlinked-target status, refusal of unconfigured test preparation, original checksum and whitespace checks pass. No actual pgTAP assertion, RLS identity probe, migration or database command has executed. Existing application UI/brand source and dependencies are unchanged by this preparation.

**Readiness for a separate development Supabase project:** repository preparation is ready for owner review/target confirmation, not runtime certification or production promotion. Verify the named empty project, install prerequisites, confirm linking/application plus rolled-back synthetic tests, and follow the prepared plan. Then execute all nine migrations/178 assertions, test concurrent transitions, inspect actual ownership/grants/query plans and generate actual types. Authentication integration, inquiry/retention operations, first-admin bootstrap and relevance-based search remain future application work. No production readiness is claimed.

## 10. Historical read-only configuration check

The owner identified `https://enyfguwoqhcprqeuhain.supabase.co` as Ghumne. A credentials-free, redirect-disabled `GET /auth/v1/settings` to that exact host returned HTTP 401 after the sandbox initially blocked networking. No other Supabase host was contacted. `.env.local` is still absent from the current checkout; only the inert `.env.example` is present. No actual publishable key was available to validate, and the dashboard project name/development purpose cannot be established from the unauthorized response.

The existing environment/client/session/checker tests pass **60/60**, and strict TypeScript passes. Git ignores `.env.local`, and it is not tracked. The user was asked to save the exact local file without sharing credentials. No environment/source/SQL file was altered by this check; only verification documentation was updated. Migration testing remains pending valid configuration, the successful keyed read-only check, confirmed development identity, tooling and explicit authorization. Counts remain **0/9 migrations executed and 178 pgTAP assertions not run**.

## 11. Historical configuration follow-up — read-only check succeeds

After the owner saved `.env.local`, redacted validation found a publishable-format key and a malformed URL. Corrected only the URL assignment to the owner's exact `https://enyfguwoqhcprqeuhain.supabase.co` address; confirmed all other parsed values, including the key, were preserved. Actual Next.js environment loading and the existing schema now resolve the same URL/key. The existing Auth settings checker succeeds using the key, with a redirect-disabled GET to that host only. No key value or response body was logged; no other Supabase project was contacted.

Git confirms the local file is ignored/untracked; strict TypeScript passes with the configuration present. Existing focused tests passed 60/60. The exact project reference identified by the owner as Ghumne is verified as the API target, but its dashboard name and separate development purpose are not independently established. CLI/Docker/psql remain unavailable, and no CLI link/development target allowlist was created. Configuration/connectivity are ready; database testing still requires confirmed development identity, tooling and explicit authorization. **No migrations or database tests were run, and no database records or deployment changed.**

## 12. Current hosted-only preparation — 2026-10-20

The owner's current instruction replaces the historical local/Docker setup: use the existing dedicated Ghumne Supabase Cloud development project only. No Docker/WSL/Linux installation or execution is needed or authorized.

| Check                               | Current result                                                                                                                        |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Target selection                    | Owner-confirmed Ghumne development purpose; exact configured reference `enyfguwoqhcprqeuhain`                                         |
| Read-only connectivity              | Fresh keyed Auth settings check succeeds against that exact host; no redirects, credential or response logging                        |
| Independent dashboard/catalog check | Pending: no browser session/Management API credential to inspect name/organization, version, emptiness or history                     |
| Local allowlist                     | Created ignored `supabase/dev-target.local.json`; planned-target guard passes; credentials preserved                                  |
| CLI tooling                         | Not found on PATH, in project dependencies/bin or inspected Chocolatey/Scoop paths; native psql/pg_prove not found; nothing installed |
| CLI link/history/dry run            | None executed; exact Windows commands prepared for dedicated profile and isolated workdir                                             |
| Migration source/order              | All nine files inspected and preserved in dependency order; existing repairs retained; full stored reason limits aligned in 002/004   |
| RLS source review                   | All 54 policies/46 tables, grants, tenant FKs, escalation and definer boundaries reviewed; [full inventory](supabase/RLS_REVIEW.md)   |
| Migration execution                 | **0 executed by this workflow**; actual hosted history remains to be inspected                                                        |
| pgTAP execution                     | **206 not run** (81 unchanged + 125 boundary/security); no runtime pass/fail result                                                   |
| First-file approval                 | Isolated local 001-only snapshot/manifest prepared; preflight/history/one-file plan precede approval                                  |

The 2,000-character audit limit was already present in draft 001. This review also found that approval/review records counted trimmed text while audit and verification notes counted stored text. Drafts 002/004 now reject blank reasons and bound full stored text to the same 2,000 characters, including surrounding spaces. Prepared probes exercise exact limits, preserved whitespace and atomic failure; no live constraint was changed.

The boundary suite grew from 97 to 125 assertions. Added coverage includes per-group discounted tier selection without multiplying the group base, full mandatory person fees across discount boundaries, remaining fee quantity combinations, exact multiplication ceiling/overflow, explicit-zero versus unknown base, unsupported 100%/stacked discounts, stored-space/blank reason boundaries, agency-state rollback, cross-agency draft updates, private ledger/anon access and revoked membership with retained agency role.

The complete RLS inspection found no direct source-level tenant/role bypass in the reviewed policies/grants. This is not deployed security verification. Permissive policy OR behavior, trusted definer-owner bypass, intentionally shared plan reads and inquiry traveler/agency/admin access are documented. Actual function/table owners, inherited grants, hosted private-schema exposure, real Auth/API identities, concurrent revocation/transitions and query plans remain required checks. Some RPC rejection paths distinguish missing IDs from unauthorized IDs; application error mapping/API probes remain necessary.

The [cloud workflow](SUPABASE_DEVELOPMENT_SETUP.md) uses a locally fingerprinted workdir containing **001 only**, because db push otherwise applies all pending migrations. It includes native Windows CLI installation/login/link, read-only catalog preflight/history, the isolated dry run, exact 001-only approval wording and the gated apply command. 002–009 and synthetic test writes remain separately gated. A later-file failure preserves the committed prefix; no reset/drop/automatic history repair is supplied.

Docker-free pgTAP can run inside the hosted SQL Editor, or through an optional native Windows psql client using the exact project's direct/session-pooler connection and validated TLS/private password prompt. Generated copies retain rollback/fixture guards, use fixed 81/125 plans and finish(true) to raise SQL errors for failed assertions/incomplete plans, with a post-rollback marker. ON_ERROR_STOP makes the psql path fail on those errors. The CLI test db runner is excluded because it uses a container even with --linked. The original first suite remains checksum-identical. Complete suites require all nine approved/applied migrations; they cannot certify a schema containing only 001.

No migration contains another-project connection, remote database URL, dblink/FDW/network call, schema reset or billing operation. SQL effects are confined to the database selected by the connection; the SQL itself cannot detect a wrongly selected project. The pinned reference, isolated workdir and checked history/plan constrain that selection. No other project/Mount Kailash was accessed; no migration, destructive database command, deployment or billing activation occurred.

**Stop before application:** verify the exact dashboard/organization/catalog, install/link the CLI, inspect empty history and the one-file dry run, then obtain explicit approval for the reviewed 001/hash only. No database security certification is claimed.

**Final local validation:** `npm.cmd run check` passes formatting, lint, strict TypeScript, all migration/test/preflight SQL/PL/pgSQL/probe syntax, **111 local tests in seven files** and production build. Planned-target checks, actual staged 001-only/hash validation, generated-copy SQL parsing, original checksum and whitespace checks pass. Git confirms credentials, allowlist and generated copies/snapshot are ignored; credentials/allowlist are untracked. The first-file SHA-256 is `d144d34a2dc6187384bfbd52cb280e10480a6b92de2b27eda0544addb8f044c1`; the ignored manifest fingerprints all nine originals/configuration. These are offline results, not hosted migration/pgTAP or RLS execution evidence.
