# Application architecture

Updated: 2026-10-20. Product and logical database authority: [GHUMNE_MASTER_SPEC.md](GHUMNE_MASTER_SPEC.md), especially sections 3, 5 and 6. This document distinguishes the implemented application foundation, unapplied SQL foundation and future marketplace modules. [V1_BUSINESS_POLICIES.md](V1_BUSINESS_POLICIES.md) and [DATABASE_IMPLEMENTATION_REVIEW.md](DATABASE_IMPLEMENTATION_REVIEW.md) record policy and review gates.

## Implemented foundation

Ghumne is one Next.js App Router application with strict TypeScript, React, Tailwind semantic tokens, Zod configuration validation, Vitest and Supabase SSR client factories. Preserve these files and their existing tests.

The public route group provides the approved Stitch homepage and shared responsive header/footer. Seven reusable sections in `src/components/home` compose typed editorial previews, native GET destination search, client-side itinerary filters, a local downloadable trip brief, stories and agency information. `src/features/home` owns preview contracts, query normalization and pure filtering/brief logic. These presentation contracts do not expose live inventory or call Supabase. Root/public error boundaries, loading/not-found UI and reusable feedback components remain. `/ui-preview` returns not-found outside development. Other domain/auth/dashboard directories contain markers, not functionality.

Supabase browser/server clients and a session-refresh helper are present. No `src/proxy.ts` wires that helper into requests yet. Nine SQL migration drafts now define database authorization, entities and workflows, but none have been executed. No application tables/data, schema-generated types, auth pages, application role guards, Server Actions or API endpoints have been deployed. `database.types.ts` intentionally permits no tables/RPCs. Live Supabase integration remains unverified.

## Module responsibilities

| Location                                                 | Responsibility and state                                                                                       |
| -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `src/app/(public)`                                       | Existing shell; future destination, agency/package details, search, Finder and public planning routes          |
| `src/app/(auth)`                                         | Marker; future signup/login/reset/callback routes                                                              |
| `src/app/dashboard`                                      | Marker; future traveler-owned trips/favorites                                                                  |
| `src/app/agency`                                         | Planned agency workspace; active membership and tenant checks on every operation                               |
| `src/app/admin`                                          | Marker; future server-verified Ghumne Admin workspace                                                          |
| `src/app/api`                                            | Marker; introduce handlers only for concrete endpoint/callback needs                                           |
| `src/components/ui`, `layout`                            | Implemented accessible primitives, feedback, navigation and footer                                             |
| `src/components/home`, `src/features/home`               | Implemented Stitch presentation, typed editorial data and pure local search/planning logic                     |
| `src/components/destination`, `trip`, `partner`          | Existing markers; future typed presentation. Reuse partner folder rather than cosmetic renaming                |
| `src/components/dev`, `src/app/(development)/ui-preview` | Existing isolated component verification, never live inventory                                                 |
| `src/features/destinations`                              | Marker; future editorial content, source/freshness and destination queries                                     |
| `src/features/recommendations`                           | Marker; future pure destination scoring/explanations and self-plan suggestions                                 |
| `src/features/trips`, `auth`, `agencies`, `inquiries`    | Markers; future owned trip operations, identity, tenant onboarding and secure lead workflow                    |
| `src/features/packages`, `moderation`                    | Planned owned package revisions, itinerary, review and publication transitions                                 |
| `src/features/pricing`, `availability`                   | Planned pure group quotes/estimates and agency-confirmed calendar/capacity compatibility                       |
| `src/features/subscriptions`                             | Planned versioned entitlements, admin assignments, publishing limits and time validity                         |
| `src/features/search`                                    | Planned shared request normalization and destination/package result orchestration                              |
| `src/features/promotions`, `analytics`                   | Planned labeled placements and first-party events/entitled aggregates                                          |
| `src/lib/supabase`                                       | Implemented request/browser clients, session helper and empty database type boundary                           |
| `src/lib/env`                                            | Implemented explicit public configuration validation                                                           |
| `src/lib/auth`, `validation`, `src/types`                | Markers; introduce shared identity/permission/schema/contracts only with consumers                             |
| `src/lib/utils`                                          | Existing small class-name helper; keep utilities focused                                                       |
| `src/tests/unit`, `scripts`                              | 121 unit/static-contract/target/planning tests, offline checks, source-asset preparation and browser launchers |
| `src/tests/e2e`, `playwright.config.ts`                  | Feedback, production, homepage interaction/reflow/accessibility and isolated reference screenshot verification |
| `supabase/migrations`, `supabase/tests`                  | Nine unapplied migration drafts and guarded, unexecuted pgTAP scenarios                                        |
| `src/tests/integration`, `supabase/seed`                 | Future application integration/seed-import tooling; not created by this task                                   |

Remove a `.gitkeep` when adding its first implementation. Planned directories do not require empty placeholder routes. Link only to completed routes. Proposed package route: `/agencies/[agencySlug]/packages/[packageSlug]`, matching per-agency slug uniqueness.

## Dependency direction

Routes compose feature services and typed presentation. Presentation uses shared UI/domain contracts and never receives a Supabase client, privileged configuration or raw session. Feature services use their own validation/data-access adapters and shared libraries. Shared libraries do not import routes/presentation. Avoid barrels mixing server and browser code.

Use Server Components by default and client components for interaction. Mark database access/privileged helpers `server-only`. Actions/handlers verify identity, role, tenant and field permissions, validate input, call a domain service, then return a safe result. Request-scoped session clients remain centralized; no general service-role client is added by this plan.

Keep pricing, budget units, eligibility, matching and explanations testable without UI/network. Centralize shared package eligibility in a database-safe predicate/projection plus a domain contract; do not duplicate divergent checks across pages. A general package lifecycle service coordinates moderation, subscriptions and agency state without circular feature dependencies.

## Public query flow

1. Normalize destination/Finder/plan inputs into total group budget, travelers, origin, duration, interests and dates.
2. Read published destination content and candidate offers through public-safe RLS/projections.
3. Require approved active agency, current publishing subscription, approved published revision and compliant quota; compute group quote and applicable date/capacity status.
4. Separate exact offers from explained alternatives and unchecked dates. Return independent destination recommendations/self-planning options even with zero packages.
5. Rank organic candidates deterministically. Insert eligible placements only in labeled Sponsored surfaces; plans cannot alter organic scores.
6. Revalidate eligibility/quotes before inquiry or reopening historical comparisons. Search/inquiries never reserve seats.

No manual featured assignment is required for organic matching. Multiple agencies may match the same destination, and revisions can associate with several destinations.

## Write boundaries and lifecycle

Agency member -> verified tenant service -> owned draft/revision. Admin review approves an immutable revision; an eligible agency then publishes through an atomic transition that locks the agency and checks quota. Public pointers never expose a draft. Material price/content edits create a new reviewable revision. Availability refresh is separately owned, timestamped and audited.

Admin -> plan version/subscription assignment -> effective entitlements. Manual activation is the initial model, subject to commercial approval. UTC periods are checked at read/write time. Expiry/suspension removes eligibility under the proposed policy; it does not delete records. Quota reductions require resolving which listings remain published before reactivation. Membership and subscription state are never writable through public company-profile forms.

Traveler/guest -> validated inquiry service -> package-derived agency FK + quote snapshot -> protected agency inbox. Consent, durable rate limiting and deduplication precede the database write. Use a narrow database operation; no anonymous arbitrary table insert. No email/WhatsApp message is sent by this flow. WhatsApp/external booking buttons are user-initiated links.

## Data design summary

The master specification owns field-level logical design. Identity uses `profiles`, trusted `user_roles`, `agencies` and `agency_memberships`. Agency membership supplies tenant access; traveler/agency capabilities may coexist. Destination knowledge uses normalized locations, destinations/media, interests/seasons, attractions/activities, unit-based costs and transport.

Plans have immutable entitlement versions and agency subscription periods. Packages have immutable approved revisions and revision-scoped destinations/origins/interests, itinerary, pricing and availability. Use integer minor units and person/group/unit quantities rather than a single `price_from`. Traveler trips/days/items, revocable shares, favorites and comparison snapshots remain owner-scoped. Inquiries, featured placements, minimal events and audit logs complete marketplace operations.

Same-tenant composite FKs, legal state transitions, nonoverlapping subscription/price scopes and transactional quotas prevent orphaned or foreign agency references. RLS/grants apply to every application table, including lookup data, with explicit public reads. Narrow views/functions preserve eligibility and safe columns. Public media and private verification storage have separate policies.

## Authentication, caching and privacy

Wire `updateSupabaseSession` through `src/proxy.ts` before any authenticated server rendering; preserve SDK cookies/cache headers in handlers as well. Folder location is not access control. Verify current trusted role/membership on sensitive operations; do not trust client roles or editable metadata.

Private pages/responses are never shared-cached. Public listing caches are bounded by subscription, price, availability and placement expiry and invalidated on approvals, suspension, publication, entitlement and price/availability changes. Direct package routes cannot leak now-ineligible listings. Correctness cannot depend on a background expiry job alone.

Events contain no inquiry bodies or contacts. Agency analytics only aggregate its own data under current plan permissions. Shared-trip tokens are hashed, revocable and reveal a safe read-only projection without private notes or contacts. Retention/consent policy is pending owner approval.

## Verification and migration boundaries

Current checks are local: formatting, lint, strict types, 121 unit/static-contract/target/planning tests, PostgreSQL SQL/PL/pgSQL/probe/preflight syntax parsing and build. Browser suites verify feedback and homepage interactions, reflow, keyboard use and automated accessibility; actual results are recorded in `PROGRESS.md`. They establish local UI/contracts, not live database/auth/RLS correctness. The homepage replaces the earlier minimal shell; Supabase and database boundaries remain intact.

`supabase/migrations/202610200001` through `009` retain the unapplied schema/workflow bundle. Draft 001 permits 2,000-character audit reasons; 002/004 now apply that limit to full stored review reasons. Existing repairs in 006/007 are preserved. The original 81 assertions in `supabase/tests/0001_marketplace.test.sql` are unchanged; the boundary suite now has 125, for 206 prepared assertions. Generated cloud copies use fixed plans and finish(true), transaction-local fixture opt-in and rollback. No assertion has executed. Real constraint/RLS and parallel-session race checks require the approved hosted test target. No migration runner is part of the quality gate.

`supabase/config.toml` is CLI configuration, not a hosted link or remote Auth configuration. Development is **Supabase Cloud only, with no Docker/WSL/Linux**. The app and ignored allowlist match the owner-confirmed Ghumne reference; keyed Auth settings are reachable, but CLI link and independent catalog/history checks remain pending. Offline scripts guard target identifiers and prepare a fingerprinted **001-only** workdir for first-file approval. [SUPABASE_DEVELOPMENT_SETUP.md](SUPABASE_DEVELOPMENT_SETUP.md) records exact native Windows CLI commands and hosted SQL Editor/optional psql testing. No local stack is required or authorized.

Review the schema/RLS/grant/index bundle, confirm the separate named development target, apply only after authorization, then generate actual types and run integration checks. Production application/deployment require separate authorization; Mount Kailash is outside scope. No paid maps, search, AI, analytics, billing or messaging was provisioned. Prior targeted framework security patches are preserved; this preparation changes no runtime package or application UI.
