# Implementation decisions

Product decisions DEC-001 through DEC-006 originated in `GHUMNE_MASTER_SPEC.md`. DEC-015 supersedes the former secondary-marketplace direction. Decisions below distinguish historical implementation from the revised design and unapproved policy proposals; they are not migration or service-provisioning approval.

## DEC-007 — Initialize the missing application incrementally

Date: 2026-09-27. Related tasks: TASK-001, TASK-002.

The workspace initially contains only the master specification. Create the application manually in this directory to preserve it and keep each task reviewable. Use npm because it is already installed, with a committed lockfile and exact direct dependency versions. Initialize local Git history for the specification's task-by-task commit workflow; do not configure a remote or publish anything.

Follow the specified Next.js App Router modular monolith with `src/` and strict TypeScript. Keep the initial route limited to a product identity and message; implement the homepage experience in its assigned task. Add libraries when a task concretely needs them.

Current framework guidance: [Next.js installation](https://nextjs.org/docs/app/getting-started/installation). Verify package versions against the npm registry when installing.

## DEC-008 — Foundation runtime and verification tooling

Date: 2026-09-27. Related tasks: TASK-002, TASK-004.

Use Node.js 24, Next.js 16.3.6 and React 19.3.0, verified against npm's stable releases at installation. Use TypeScript 6.0.3 and ESLint 9.39.5 to satisfy the peer ranges of Next.js's lint plugins: typescript-eslint requires TypeScript below 6.1 and eslint-plugin-react supports ESLint through 9. A dependency compatibility check (`npm ls`) passes and npm reports zero known vulnerabilities at installation. npm marks ESLint 9 unsupported; revisit the pin when Next.js's plugin set supports ESLint 10. Do not bypass peer checks.

Add the basic ESLint command in TASK-002 because every code task requires lint verification. Complete formatting and the aggregate quality gate in TASK-004. Run `next typegen` before `tsc --noEmit` so type checks work on a clean checkout. Keep external fonts and service connections out of the initial build.

The Windows execution sandbox owns files under a different account and makes `.git` read-only. Git operations use a command-scoped `safe.directory` for this workspace and reviewed escalation for writes; global Git configuration is unchanged.

## DEC-009 — Tailwind CSS configuration

Date: 2026-09-27. Related task: TASK-003.

Use Tailwind CSS 4.3.3 through `@tailwindcss/postcss`, imported in the root global stylesheet. Tailwind 4 uses CSS configuration and automatic source discovery, so no legacy `tailwind.config.js` or Autoprefixer dependency is needed. Keep neutral base colors, a local system font, focus visibility, and reduced-motion defaults here; product design tokens and typography remain TASK-008 and TASK-009.

Reference: [Tailwind PostCSS setup](https://tailwindcss.com/docs/installation/using-postcss).

## DEC-010 — Public service configuration and test boundary

Date: 2026-09-27. Related tasks: TASK-005, TASK-006.

This new Supabase integration uses a project URL and modern publishable key. No privileged client or service-role variable is needed for session-scoped server/browser clients. Reject legacy JWT keys and secret keys in public configuration; the project has no legacy integration to preserve. Require HTTPS except for local loopback development. Validate only named public fields, and report field names without values.

Validate at use time and also when Next.js loads configured values before bundling. Both values may be absent while the foundation has no Supabase-consuming route; partially supplied or invalid values must fail. This keeps static development possible while preventing a secret pasted into public configuration from reaching a build. Public values are build-time values; changing them requires a rebuild.

Add Vitest at TASK-005 because validation now introduces security-sensitive testable logic. Tests use inert fixtures and do not load local credentials or contact Supabase. The unit suite is part of `npm run check`.

References: [Supabase API keys](https://supabase.com/docs/guides/getting-started/api-keys), [Next.js environment variables](https://nextjs.org/docs/app/guides/environment-variables).

## DEC-011 — Supabase session boundaries

Date: 2026-09-27. Related task: TASK-006.

Use `@supabase/ssr` factories with publishable configuration. Server clients are request scoped and marked `server-only`. Server Components use read-only cookies; Server Actions explicitly enable writes. Do not suppress arbitrary cookie errors. The refresh helper forwards request/response cookies and preserves the SDK's cache prevention headers. Wire it to consuming routes before authenticated server rendering; no such routes exist yet. Route Handler responses must also carry cache prevention headers when setting auth cookies.

Keep an empty typed database boundary until migration-generated types exist. It represents no implemented application tables and prevents accidental untyped queries. Do not invent a schema ahead of Phase 3.

Use explicit ESM package configuration and TypeScript import extensions for the shared pure environment parser so Node.js 24 can run the connectivity script without an additional runner or duplicate validation.

References: [Supabase SSR clients](https://supabase.com/docs/guides/auth/server-side/creating-a-client), [Supabase Auth settings response](https://github.com/supabase/auth/blob/master/internal/api/settings.go). Installed SDK types were also reviewed for cookie/cache-header behavior.

## DEC-012 — Keep credential requirements scoped to live integration

Date: 2026-09-27. Related tasks: TASK-006 onward.

On resumption, all 60 existing tests and the quality gate passed. TASK-006 configures client code; its local acceptance checks are complete. The specification does not require a live connection before folder architecture or design-system work. Correct the prior blanket blocker and continue sequentially through work that does not consume a live service. Keep live verification explicitly pending and stop when a task actually requires a provisioned database or user-specific service settings. Do not invent credentials, weaken validation, or treat mocked tests as proof of live integration.

## DEC-013 — Preserve focused environment and test modules

Date: 2026-09-27. Related task: TASK-007.

Use the specification's folder architecture with `lib/env` for configuration and `tests/unit` for isolated tests. Retain database types beside the Supabase adapter until migration generation provides their source. Track unused module directories with markers; add implementations only in their assigned tasks. `ARCHITECTURE.md` documents ownership and import direction without adding an abstraction framework.

## DEC-014 — Accessible semantic design defaults

Date: 2026-09-27. Related tasks: TASK-008 onward.

The specification gives visual principles rather than fixed brand values. Use forest-green primary actions, warm neutral surfaces, and a small clay accent. Semantic colors, dimensions, radii, and motion settings live in one CSS token file. Document supported contrast pairings and usage in `DESIGN_SYSTEM.md`; feature components should consume those roles. Tailwind's static theme output keeps tokens available to both utilities and plain CSS ([theme variables](https://tailwindcss.com/docs/theme)).

## DEC-015 — Three core experiences and an early marketplace foundation

Date: 2026-10-20. Status: accepted product direction from the user. Related: TASK-124, revised master specification.

Supersede DEC-001's secondary marketplace and former Phase 11 dependency. Travel Discovery, Travel Package Marketplace and Smart Trip Planning are core MVP experiences. Move identity/tenant, agency, subscription, review and package foundations before public matching. Preserve TASK-001 through TASK-014, stable task IDs, working UI/clients and TASK-015's unfinished verification. Add TASK-124 through TASK-145 for the reconciliation and missing marketplace work; do not restart the application.

Retain DEC-002/003/005/006. Expand DEC-004: inquiries, user-initiated WhatsApp and external booking links first; no payments, automated subscription billing, reservations or commissions. This task authorizes documentation only, not implementation of later tasks.

## DEC-016 — Tenant membership and trusted capability grants

Date: 2026-10-20. Status: proposed database design; no schema applied. Related: TASK-016/017/087/131.

Replace the planned self-contained `profiles.role`/`partner` concept with trusted traveler/agency/admin role grants and agency memberships. An agency member can also plan personal trips. Active membership plus capability gates each tenant action; admin remains controlled. Composite foreign keys and field-sensitive operations prevent cross-agency child rows or self-approval/subscription activation. No migration from a real old role column is needed: the current application schema is empty.

Proposal requiring policy approval: one active owner per agency initially, staff/multi-owner support later. Role, ownership, review and entitlement mutations use controlled operations, never company-profile writes.

## DEC-017 — Versioned offers, complete group prices and explicit availability

Date: 2026-10-20. Status: proposed database/domain design. Related: TASK-127/134/135/136.

Replace planned single destination/price_from/free-text-itinerary packages with multi-destination revisioned offers, structured itinerary, price rules/components and agency-reported date availability. Keep approved published revisions immutable; material content/price changes require another review. Tenant-consistent published pointers avoid exposing draft edits. Availability refresh is separately timestamped/audited.

Budget is total for all travelers. Use integer minor units and person/group tiers plus mandatory unit-based fees; price_from is derived display only. Unknown required expenses prevent exact affordability claims. Planning ranges remain separate. Compare consistent origin, travelers, dates, duration and inclusions. Snapshots are historical, not price locks.

Proposed initial scope requiring approval: NPR, uniform traveler rates, fixed duration and confirmed fixed departures/windows. Child/room-specific pricing is deferred until modeled. No invented inventory, zero-filled unknown costs or real-time booking guarantees.

## DEC-018 — Time-bounded subscription entitlements without billing

Date: 2026-10-20. Status: required capability; operational/commercial policy pending. Related: TASK-126/133/134/143/144.

Model plans, immutable entitlement versions and agency subscription assignments separately. Plans gate publishing limits, analytics and promotional eligibility, not organic rank. Initial assignments/renewals are manually administered; agency requests cannot grant entitlement. Enforce effective periods, quotas and transitions transactionally, including concurrent publish attempts. Cache/direct reads enforce current eligibility without depending only on scheduled expiry.

Proposed expiry/downgrade policy: remove public eligibility immediately, preserve data/inquiries, resolve over-limit published selections before reactivation. Owner must approve this behavior and supply names, fees, limits, durations, trial/grace rules and promotional allowances. No plan prices or paid billing service are introduced.

## DEC-019 — Shared automatic matching with labeled fallback and sponsorship

Date: 2026-10-20. Status: accepted product rules; matching defaults proposed in specification section 3. Related: TASK-093/138/139/140/141/144.

Destination search, details, Finder and plan comparison share eligibility/quote/matching rules. Published eligible offers enter organic results automatically. Rank deterministically and explain fit. Exact matches enforce destination, fixed duration, whole-group affordability, group tier, origin, requested interests and applicable confirmed dates/capacity. With no dates, label availability unchecked. Proposed V1 interest rule is overlap with at least one selection; explicit must-have filters stay strict.

Alternatives explain relaxed preferences without relaxing approval, subscription or isolation. Separate unpriced/on-request options from affordable confirmed matches; always retain the self-planning route. Sponsored content has a visible Sponsored label, separate placement and organic/sponsored event attribution. Entitlement does not alter organic rank or permit ineligible content. Placement allowance/allocation/commercial terms still require approval.

## DEC-020 — Protected inquiries, minimal analytics and safe sharing

Date: 2026-10-20. Status: proposed design; privacy policy pending. Related: TASK-075/096-101/109-114/128/143.

Derive inquiry agency from package/revision on the server and snapshot the recalculated quote. Use validated, consented, durably rate-limited/deduplicated writes through a narrow operation. Guest callers cannot insert arbitrary tenant/status rows. Deliver initially to the owning agency inbox. Automated email/SMS/external messages are not part of this plan. WhatsApp and booking buttons are traveler-initiated links.

Keep contact details/private notes out of public results, event payloads and safe shared-trip projections. Revoke hashed unguessable share tokens. Analytics expose only the current agency's entitled aggregates; audit sensitive transitions without unnecessary PII. Owner must approve consent wording, retention, verification evidence handling and abuse-control policy before launch.

## DEC-021 — Approval gates and evidence-based progress

Date: 2026-10-20. Status: accepted user constraint and documentation workflow. Related: TASK-124/125/129/130/145.

No database migrations may be applied, data deleted or paid services introduced without approval. Draft schema, constraints, RLS, grants and indexes together; review, select the target and obtain explicit permission before application. Generate types from actual approved schema and verify real RLS in an isolated local/test environment. Production has separate application/deployment approval. Do not treat this document as permission to provision a service.

Current foundation checks pass with 60 isolated tests; they do not prove live Supabase, database policies, browser journeys or deployment. TASK-015 code exists but remains in progress until targeted feedback/error UI checks and its completion record are finished. A deployment-named commit alone proves no production service. Historical task logs remain historical, and the revised plan is not implemented functionality.

## DEC-022 — Finish feedback verification without rebuilding components

Date: 2026-10-20. Status: implemented and locally verified. Related: TASK-015.

Existing feedback/loading/error/not-found components required no production rewrite. Add six meaningful unit tests for semantics/confidentiality/reset contracts, six browser scenarios for keyboard/axe/reflow/reduced motion/recovery, and production preview-gating smoke coverage. Preserve existing runtime UI and library versions. Add exact development-only Playwright/axe dependencies and a PostgreSQL WASM parser for the user's requested checks. Pin playwright-core to match the test runner and avoid incompatible peer Page types. Reuse an existing local development server; never stop it as test cleanup. Only the owned temporary production server is disposable.

The full quality gate passes with 84 unit/static-contract tests, lint, strict types, SQL/procedure syntax and production build. Seven browser tests pass. The managed Windows sandbox required explicit cleanup of the verified temporary port-3126 process; this does not imply a product failure or authorization to terminate unrelated processes.

## DEC-023 — Establish the owner's provisional V1 policies

Date: 2026-10-20. Status: provisional policy baseline accepted for authoring; final commercial choices open. Related: TASK-125. Authority: current user instructions.

[V1_BUSINESS_POLICIES.md](V1_BUSINESS_POLICIES.md) supersedes earlier unresolved V1 wording: registration is free, business approval manual, new/material packages moderated, reconfirmation every 30 days, NPR/person/group pricing, inquiry/WhatsApp/external conversion, configurable free-pilot/monthly/annual plans, retained expiry data, labeled sponsorship, relevance-first organic results and minimal/configurable retention.

Document assumptions separately: one owner, manual activation, Nepal calendar month/year periods, no implicit grace, explicit pilot dates, conservative promotion overlap, uniform traveler rates and disabled inquiry collection until retention/server controls are configured. Names/prices/limits/pilot duration, evidence/appeals, sponsorship allocation, consent/retention execution and launch environment remain final decisions. No actual commercial plan or company data is seeded.

## DEC-024 — Author the protected database bundle; keep it unapplied

Date: 2026-10-20. Status: SQL authored/static-checked, runtime integration unverified. Related: TASK-016/017/018/019/020/087/126/127/128; application/type generation remain TASK-129/130.

Prepare nine transactional Supabase PostgreSQL 17 migration drafts with 45 public tables and a private request ledger. Use trusted role grants/memberships, same-tenant composite keys, immutable review/plan/revision history, ordered itinerary and licensed media metadata, nonoverlapping price/subscription scopes, integer group quotes and agency-row locks for quota/lifecycle transitions. Public reads use curated safe projections with current eligibility; base tables have RLS and revoked API defaults. Sensitive writes use fixed-search-path RPCs with explicit grants and database-backed authorization; approved content cannot be edited through direct draft writes.

Effective publishing entitlement includes current period, configured plan price (including a zero-price pilot), listing limit, agency approval/operation, approved revision/current pricing and matching reconfirmation within 30 days. Expiry is evaluated at reads, without deletion or reliance on jobs. Separate labeled sponsorship adds its entitlement/window. Inquiry agency and quote are derived in the database, writes are backend-only and disabled by default, and retained comparison/share projections exclude unnecessary personal data.

The database type boundary stays empty until actual approved schema generation. No application auth routes, privileged server client, Storage uploads, paid service, billing, payment/commission or public marketplace UI is enabled by these SQL definitions.

## DEC-025 — Separate static evidence from release readiness

Date: 2026-10-20. Status: enforced stop/review boundary. Related: TASK-129/130 and release security gates.

The owner's current instruction explicitly stops before all migration execution/destructive changes. `npm run db:check` parses PostgreSQL, PL/pgSQL and dynamic pgTAP probe syntax without a database connection. Eighteen contract tests guard RLS/grants/function paths/eligibility/scopes/seed isolation. The guarded, synthetic, rolled-back pgTAP suite contains 81 scenario assertions but has not run. Do not claim real RLS, catalog resolution, runtime price correctness, transaction-race coverage or generated types from static parsing.

First application requires a reviewed named test target, extension/owner/schema checks and explicit permission, followed by actual database/concurrent-session tests and generated types. Production is separately approved. Online npm audit identified eight high-severity affected-package findings in existing framework/build/lint dependencies; review compatible targeted remediation before deployment, without using a force/downgrade audit fix. The review report records these risks and the remaining operational policy choices.

## DEC-026 — Apply targeted security patches; retain an explicit residual finding

Date: 2026-10-20. Status: installed; regression results recorded in progress. Authority: current dependency-security request; supersedes the earlier instruction to preserve exact vulnerable runtime versions.

Patch Next.js and matching lint configuration from 16.3.6 to 16.3.8; update sharp 0.35.4 to 0.35.5 and source-map-js 1.2.1 to 1.2.2 within their existing dependency ranges. Preserve the rest of the stack and all UI/brand source. No forced npm audit fix, downgrade or lint-rule removal. The full audit falls from eight to five high affected-package findings; the production-only audit is zero. The remaining five share the unpatched development-only braces chain. Keep that risk open rather than accepting it for release or disguising the audit. See [DEPENDENCY_SECURITY_REVIEW.md](DEPENDENCY_SECURITY_REVIEW.md).

## DEC-027 — Stop local database execution when prerequisites are absent

Date: 2026-10-20. Status: blocked before initialization/application. Authority: current local-database request; updates DEC-025's earlier blanket stop for local testing only.

The owner authorizes disposable local execution when Supabase CLI and Docker are available, and explicitly requires stopping when local tools are missing. Neither command is on PATH; checked standard Docker Desktop/CLI and Supabase shim locations are absent; psql is also unavailable. Do not install a remote substitute, link an existing project or infer production authorization. No configuration/stack/database was initialized. All nine migrations and all 81 pgTAP assertions remain unexecuted; parsing is not database validation. Discount semantics and additional exact boundary/concurrency tests remain open in the database review. A separate development project requires its own target review before remote application; production/deployment/billing remain prohibited in this phase.

## DEC-028 — Preserve V1 pricing and prepare an isolated Supabase development target

Date: 2026-10-20. Status: preparation only; no database execution or link. Authority: current user request and explicit discount-scope reply. Updates DEC-027's stop point to the requested development setup review.

Supabase PostgreSQL/Auth are confirmed. Retain the nine migrations and original 81 assertions. Repair known-unapplied draft 001 to allow the same 2,000-character audit/review reason without truncation. Harden draft 006 to reject unknown fee classifications. Correct draft 007's agency-review audit target to the verification UUID while preserving its approval-record return value. V1 discounts remain approved group tiers; negative fees and unsupported fixed/percentage-discount inputs are rejected. No coupon/stacking engine is authorized. Add a separate 97-assertion boundary/moderation/tenant suite; all 178 assertions remain unexecuted.

Prepare local PostgreSQL 17 configuration, target templates, ignored CLI state, offline planned/linked identity checks and guarded test copies. Use a dedicated Ghumne CLI profile and explicit workdir/linked flags after confirmation; never infer a safe remote identity from a project name alone. Dashboard verification must establish the exact organization/ref and separate empty development purpose. Current checkout is unlinked, has no actual credential file/target environment configuration, and no database connection was opened. Do not operate on Mount Kailash, production, deployment or billing.

The existing application consumes only the two public Supabase URL/publishable-key variables. Optional CLI credentials stay outside browser configuration and source. Full setup/commands are in [SUPABASE_DEVELOPMENT_SETUP.md](SUPABASE_DEVELOPMENT_SETUP.md). Stop for owner confirmation before linking or database changes; install prerequisites and execute real RLS/pricing/constraint/concurrency tests only in the approved environment. Static syntax/contract tests do not certify runtime security.

## DEC-029 — Hosted Supabase only; isolate the first migration approval

Date: 2026-10-20. Status: local preparation complete; no migration or pgTAP execution. Authority: current owner instruction; supersedes DEC-027/028's local/Docker workflow.

Use only the existing dedicated Ghumne Cloud development project, reference `enyfguwoqhcprqeuhain`. No Docker, WSL or Linux installation/execution, other-project/Mount Kailash access, destructive database commands, deployment or billing. The configured host/key passes read-only Auth validation; independent dashboard/catalog/history verification and CLI linking remain pending. Pin the reference in an ignored allowlist without copying or logging credentials.

Preserve all nine migration names/order and the unchanged original 81 assertions. Full stored approval/review reasons in 002/004 share the 2,000-character audit limit. Add 28 pricing/boundary/security probes to the existing 97, for 206 prepared assertions. Review all 54 policies/46 tables while keeping actual runtime security explicitly unverified.

Prepare a locally fingerprinted workdir containing only 001, because db push otherwise applies every pending file. Native Windows CLI login/link, hosted read-only catalog/history inspection and a one-file dry run precede explicit 001/hash approval. Stop after that file; further migrations and synthetic writes need separately reviewed authorization. Hosted SQL Editor or optional native Windows psql can run generated fixed-plan/finish(true)/rollback suites after all nine approved migrations. Exclude the CLI's containerized test runner. No migration was applied.
