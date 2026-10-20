# Ghumne implementation progress

Updated: 2026-10-20.

## Current state

- Completed and preserved: TASK-001 through TASK-015; TASK-006 remains complete only for its local client scope. The prior TASK-124 documentation reconciliation is preserved.
- Previously completed and preserved: TASK-015 verification/tests and TASK-125 provisional V1 policy baseline. Final commercial/retention decisions remain open, explicitly separated from the owner's provisional rules.
- SQL authoring/static-validation scope complete: TASK-016/017/018/019/020/087/126/127/128. Nine ordered migration drafts and guarded automated database tests exist; **no SQL has been executed**. These checkmarks do not certify live RLS or runtime behavior.
- Current request completed: implemented the approved Stitch V1 homepage from the complete export found at **`supabase/stitch-reference/index.html`**. Seven reusable responsive sections, original images/local fonts, exact approved palette, working preview search/filters, and a downloadable personal trip brief are present. Live agency matching, quotes, saved plans and onboarding remain future integrations. No dependencies, credentials, Supabase configuration or database files changed for this homepage.
- Preserved database boundary: **hosted Supabase Cloud only**, with no Docker/WSL/Linux. The owner confirms the dedicated Ghumne development project; its configured reference and keyed Auth connectivity match. An ignored target allowlist and isolated migration-001 snapshot are prepared. CLI installation/link, independent dashboard/catalog/history checks and first-file dry run remain pending. Stop before applying any migration. TASK-129/130 remain unfinished; no deployment, billing or other-project access is authorized.
- No application database tables/data or authenticated marketplace routes have been deployed. Existing domain/dashboard application folders remain markers. The intentionally empty database type boundary is preserved.
- Previous foundation/browser evidence is preserved. Current cloud preparation expands the boundary suite to 125 assertions: **206 pgTAP assertions remain prepared, not run; the original 81 are unchanged.** Local checks do not certify runtime security.
- Supabase Auth settings connectivity and Next.js environment resolution are verified for the supplied project. Login/session behavior and database/RLS runtime correctness remain unverified. Next gates are confirmed development identity/purpose, tooling, authorized isolated application, real database/parallel-session tests, generated types and application integration.
- Security patches installed: Next.js and matching lint config `16.3.8`, sharp `0.35.5`, source-map-js `1.2.2`; other stack versions remain intact. The homepage now applies all five approved colors. No migrations applied, data deleted, paid services provisioned, messages sent, environment credentials created or deployment performed.
- Dependency risk: full audit is now **five high findings**, all from one unpatched development-only braces chain; production-only audit is **zero vulnerabilities**. No force/downgrade audit fix or suppression was used. See [DEPENDENCY_SECURITY_REVIEW.md](DEPENDENCY_SECURITY_REVIEW.md).
- Source of truth: [GHUMNE_MASTER_SPEC.md](GHUMNE_MASTER_SPEC.md). Module boundaries: [ARCHITECTURE.md](ARCHITECTURE.md). Decisions/approval proposals: [DECISIONS.md](DECISIONS.md).

## Current request — approved Stitch homepage implemented

**Reference and inspection:** Located and read the complete 86,690-byte `supabase/stitch-reference/index.html`, including all seven sections, inline Tailwind configuration, typography, spacing, scripts and image URLs. It is unchanged. Reviewed installed Next.js 16.3.8 guides as required by AGENTS.md, existing routes/components/tokens, architecture/design/product records, metadata, feedback states and Supabase type/client boundaries before editing. The earlier root-path access issue is resolved; the prior investigation is retained below as history.

**Completed sections:** Recreated the cinematic Himalayan hero/floating search, five-image destination bento, six-card journey/filter grid, five-step Trip Finder, four value pillars, lead-plus-three stories, forest agency/process split, and matching shared header/footer. Components live in `src/components/home`; typed editorial data and pure normalization/filtering/brief logic live in `src/features/home`. Layout uses Server Components with Client Components for filters, brief generation and existing navigation. Exact Forest Green/Sand/Terracotta/Ivory/Charcoal tokens, Playfair Display/Jakarta typography, source photo placement and desktop hierarchy are preserved. Mobile/tablet layouts reflow professionally; all controls remain labeled and keyboard accessible.

**Working scope:** Native GET destination-preview search handles actual filtering and empty recovery; hub, season and traveler preferences carry into planning. Destination/itinerary links prefill Trip Finder. Region/duration/culture filters combine and reset with a useful empty state. Trip Finder produces and downloads a real local text brief, clears stale output after edits, and uses **total-group budget preferences**, not fabricated prices. Native story disclosures show clearly labeled editorial previews. Navigation uses working homepage anchors/query links. Existing loading/error/not-found boundaries remain; no fake asynchronous status or unsupported route was added.

**Truthful marketplace boundary:** All itinerary cards are visibly illustrative, without agencies, prices, ratings, reviews, package counts, verified badges or confirmed availability. Removed unsupported licensed-agency, protection, escrow, commission and fake 42-match claims. Agency publishing and automatic matching of subscribed agencies' eligible packages are explained as planned, without activating onboarding/billing. No Supabase query is made because migrations/types/live access tests are still pending. Existing environment, clients, auth architecture, migrations and pgTAP tests are preserved; database security is **not verified**.

**Assets/performance/SEO:** All 16 reference photos were accessible; no replacements. Optimized local WebP assets retain URL provenance in `public/images/home/sources.json`; original photos total approximately 600KB after optimization. Fonts use three local WOFF2 variable faces via `next/font/local` with OFL files. `next/image` supplies responsive optimization, blur placeholders and stable containers; hero is eager/high-priority, other images lazy. Homepage requests stay local with no remote fonts/CDN/Supabase calls. Added descriptive title/description/Open Graph copy and preserved one h1/semantic landmarks/skip link. No new dependency, analytics or invented Offer/Review schema was added.

**Visual comparison:** Rendered both original export and production page at 1440px/390px and inspected full-page/section captures in `test-results/homepage`. Preserved container/gutters, hero hierarchy, bento proportions, card photo sizes, form composition, four principles and story/agency splits. Significant intentional differences: approved ivory/sand replaces the source mint surfaces; honest preview labels/copy and added preference fields make some sections taller; working sticky/mobile navigation replaces placeholder auth controls; search clipping is repaired; the brief replaces unsupported matching. Source photos are only about 512px wide (hero 512×217), so large-screen softness is inherited. The heritage photo also embeds tiny source-interface strips, present in the reference; a clean higher-resolution original would improve it without changing composition. Small SVG icons replace the source icon font. See [HOMEPAGE_IMPLEMENTATION_REVIEW.md](HOMEPAGE_IMPLEMENTATION_REVIEW.md) for the detailed comparison and integration boundaries.

**Validation:** `npm.cmd run check` passes formatting, zero-warning lint, strict TypeScript, offline SQL parsing, **121 tests in eight files** and production build. `npm.cmd run test:home` passes **11/11**, including real search/preference forwarding, combined filters/empty recovery, brief download contents/stale-output clearing, keyboard navigation/disclosures, 320/390/768/1440px reflow at normal and 200% text, desktop/mobile axe with **zero reported violations**, local asset loading and screenshot capture. Existing development feedback suite passes **6/6** and production smoke **1/1** (homepage 200; `/ui-preview` 404). Browser testing found and repaired narrow-screen story/agency grid sizing, wrapping actions and preference labels; no overflow is hidden to make the assertions pass. The production smoke heading expectation alone was updated to the approved headline; existing test behavior is retained. Manual assistive-technology and production Core Web Vitals are not certified by these checks.

**Review artifacts:** [Desktop screenshot](test-results/homepage/actual-1440.png), [mobile screenshot](test-results/homepage/actual-390.png), [mobile hero](test-results/homepage/actual-390-hero.png), [reference desktop](test-results/homepage/reference-1440.png), [reference mobile](test-results/homepage/reference-390.png). These are ignored generated files. `npm run prepare:reference-qa` reproducibly caches only the original reference renderer/icon font for screenshot QA; builds do not use them. Updated README, architecture and design guidance alongside this log.

**Remaining work:** Separately approved hosted migrations, actual database/RLS/pgTAP execution, generated types, eligible public-package adapters, shared automatic matching and group quote/availability services; destination/package details, sourced full guides, authenticated saved plans, agency onboarding and secure inquiries. Confirm production image rights and obtain clean/high-resolution originals when available. No database modification/application, credential change, deployment, billing activation, Docker/WSL use or other-project access occurred.

## Earlier homepage work — reference access (resolved)

**Historical note:** The following records the earlier missing-root-path state. It is superseded by the completed implementation and actual `supabase/stitch-reference/index.html` location above.

**Design authority:** The owner approves [Google Stitch project 6447836873084984064](https://stitch.withgoogle.com/projects/6447836873084984064?pli=1) as the V1 visual foundation. Exact approved palette: Forest Green `#173D38`, Sand `#D5C6AD`, Terracotta `#C26A43`, Warm Ivory `#F6F2E9`, Deep Charcoal `#26342F`. These now replace the approximate brand tokens through named brand/semantic variables. The homepage layout must follow the reference, with adaptations only for accessibility/responsiveness.

**Inspection completed:** Reviewed the master specification, design system, architecture/progress/decision guidance, package/configuration, semantic tokens/global styles, root/public layouts and metadata, current homepage, shared header/footer/navigation, cards/buttons/form controls and loading/empty/error components. The homepage is a minimal text shell. Navigation currently links only Home; destination/package/search/Finder routes and queries are absent. Supabase application types intentionally expose no tables/RPCs. No source photography, Stitch screenshot, HTML export or image archive was found in the repository.

**Reference access:** The web reader cannot open the supplied project. No browser connection is available, and connector discovery found no Stitch plugin. A credentials-free read-only download of the exact project URL returns HTTP 200 but only the generic Stitch application shell: no Ghumne content or image elements. Its ignored copy is at `test-results/stitch-reference.html`; it is not the approved homepage export and was not executed. A readable screenshot or Stitch HTML export/image assets is required to inspect composition, typography, spacing and photography before implementing faithfully. No substitute layout was invented.

**Local export follow-up:** The owner specifies `stitch-reference/index.html`. Checked the exact absolute path `C:\Users\Acer\Desktop\CODE\GhumneAd\stitch-reference\index.html` both in and outside the sandbox: neither the folder nor file exists. Workspace asset searches and direct checks of the named reference folder in nearby Desktop/CODE, Desktop, Downloads and matching nearby Ghumne roots found no export. The only Stitch HTML is the earlier generic application shell above. A correct existing absolute path or the export saved at the specified workspace path is needed; another screenshot is not required if the complete HTML is made available. Read the installed Next.js Server/Client Component, Tailwind/CSS, image, font and metadata guidance as required by AGENTS.md.

**Completed independent work:** Updated `src/app/tokens.css` with all five exact brand colors and existing semantic role bindings, retaining status colors/white control surfaces and a darker forest hover. Updated `DESIGN_SYSTEM.md` with palette roles/contrast restrictions. Browser accessibility testing identified muted-on-sand neutral badge text at 3.88:1; changed only its presentation to Deep Charcoal on Sand at 7.75:1. Forest/ivory is 10.67:1 and charcoal/ivory 11.64:1. Terracotta remains a decorative/large-text accent because normal white/ivory text contrast is insufficient. Existing navigation, route logic, Supabase configuration/types, migrations and tests are preserved; no dependencies were added.

**Verification:** After the palette/badge changes, `npm.cmd run check` passes formatting, lint, strict TypeScript, offline SQL parsing, **111 tests in seven files** and production build. The existing development browser suite passes **6/6**, including keyboard recovery, axe with zero reported violations on tested surfaces, four widths (320/390/768/1440), doubled text/reduced motion and 404 recovery. Development logs include hydration warnings from tests mutating the document's root font-size; existing tests were preserved. Production smoke passes **1/1**, confirming the homepage returns 200 with one main/h1 and developer preview returns 404; temporary server cleanup completes. Formatting/whitespace checks pass. These checks do not certify an implemented Stitch layout. No new homepage sections or reference-fidelity claims are reported.

**Remaining implementation:** Obtain the actual HTML export at the specified path (or a correct existing absolute path), inspect all sections/style/image references, then compose reusable responsive hero/destination/package/Trip Finder sections without redesigning the approved layout. Use optimized Next.js images with documented sources; retain shared navigation and feedback conventions; provide honest demonstration/empty content without fabricated agencies/reviews/prices/availability or unsupported protection/escrow/commission/verification claims; enable search only where actual route/logic support exists. Keep typed presentation boundaries ready for future server queries without querying the unapplied schema. Then run lint/types/tests/build and desktop/tablet/mobile/accessibility/visual checks, capture desktop/mobile screenshots, compare with the reference and record actual results. No database migration/application, credential change, deployment or unnecessary dependency is authorized.

## Previous request — hosted-only migration preparation

**Target/evidence:** The owner confirms the existing dedicated Ghumne Supabase project is for development. Exact configured reference: `enyfguwoqhcprqeuhain`. A fresh keyed, redirect-disabled Auth settings GET to that exact host succeeds. No credential/response contents were printed. Created only the ignored, nonsecret development allowlist; existing credentials were preserved. Dashboard display name/organization, PostgreSQL version, empty schema and migration history could not be independently checked: no browser session or Management API credential is available. Those checks remain explicit preflight gates, not inferred from the project name.

**SQL/order/reasons:** Inspected all nine originals in 001–009 dependency order; none renamed/removed/added/applied. Draft 001's existing 2,000-character audit repair is preserved. Drafts 002/004 now count full stored approval/review reasons, including surrounding spaces, against that same limit and reject blank reasons. Existing repairs to discount classification and verification audit references are preserved. No live database constraint changed.

**Additional prepared tests:** Added 28 assertions to the existing 97 boundary assertions (125); original 81 remain checksum-identical, for **206 total**. New checks cover per-group discounted tiers with full mandatory person fees, all fee quantity combinations, explicit-zero/unknown base, exact multiplication ceiling/overflow, unsupported 100%/stacked discounts, full-text/blank reason limits and state rollback, cross-agency draft mutation, private ledger/anon role access and revoked membership despite a retained agency role. All 206 remain unexecuted.

**RLS review:** Reviewed all **54 policies across 46 tables**, overlapping permissive policies, tenant FKs/column grants, definer actor checks, role administration and anonymous projections. The complete inventory/findings are in [supabase/RLS_REVIEW.md](supabase/RLS_REVIEW.md). No source-level direct tenant/role bypass was identified. Actual owners/grants, hosted schema exposure, real API identities, concurrent revocation/transitions and query plans remain unverified. No database security verification is claimed.

**Cloud-only workflow:** Rewrote [SUPABASE_DEVELOPMENT_SETUP.md](SUPABASE_DEVELOPMENT_SETUP.md). Supabase CLI is not found on PATH, in project dependencies/bin or inspected Chocolatey/Scoop paths; psql/pg_prove are not found. No tool was installed. Prepared native Windows CLI login/link/history/dry-run commands with a dedicated profile and explicit project reference. A local-only script stages just migration 001 and fingerprints all nine/configuration; guards reject changed or extra files and wrong links. Plain db push otherwise applies every pending file. The first approval therefore covers **001 only**, then stops; 002–009/test writes need later authorization.

**Docker-free pgTAP:** Prepared SQL Editor/native Windows psql routes. Generated copies opt into fixtures only inside their rollback transaction, use fixed 81/125 plans and `finish(true)` so failed assertions/incomplete plans raise SQL errors, plus a marker after rollback. psql uses ON_ERROR_STOP, TLS validation and a private password prompt. The CLI's containerized test db runner is excluded. All nine migrations and separate fixture-write approval are prerequisites for executing the complete suites.

**Checks/stop:** `npm.cmd run check` passes formatting, lint, strict TypeScript, all migration/test/preflight SQL/PL/pgSQL/probe parsing, **111 local unit/static-contract/guard tests in seven files**, and production build. Planned-target checks, actual one-file snapshot/hash validation, generated-copy SQL parsing and original checksum pass. Git confirms credentials/allowlist/generated files are ignored and credentials/allowlist are untracked; whitespace checks pass. First-migration SHA-256: `d144d34a2dc6187384bfbd52cb280e10480a6b92de2b27eda0544addb8f044c1`. **0 migrations applied and 0 pgTAP assertions executed.** No Docker/WSL/Linux, destructive database operation, deployment, billing or other-project/Mount Kailash access occurred. Await dashboard/catalog/history verification, the isolated one-file dry run and explicit approval of migration 001.

## Previous request — read-only Supabase configuration check

**Verified target/result:** configuration and Next.js environment loading resolve to exactly `https://enyfguwoqhcprqeuhain.supabase.co`, the project the owner identified as Ghumne. The existing read-only checker successfully retrieved/validated Auth settings with its publishable key, using a redirect-disabled GET to that host only. No key, credential fragment or response body was printed. The endpoint/key pair is verified; the dashboard display name and development/production purpose are not independently verified.

**Local configuration repair:** the file was initially absent and the credentials-free endpoint check returned 401. After the owner saved `.env.local`, its publishable key passed format validation, but its URL was malformed. Corrected only that assignment to the exact owner-supplied URL; verified every other parsed value, including the key, was unchanged. The file now passes the existing schema and actual Next.js development environment resolution. No credentials were invented, copied into source, printed or changed.

**Compatibility/Git checks:** existing clients use `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` with the modern publishable-key validator and installed SSR SDK. All **60 environment/client/session/checker tests in four files** pass, and strict TypeScript was rerun successfully with the actual configuration present. `.gitignore:12` excludes `.env.local`; `git ls-files` confirms it is untracked. CLI link and local development target files remain absent. No runtime application source, package, SQL or test file changed.

**Readiness:** the application-configuration/connectivity gate is complete. Migration testing still needs verification that this is the separate approved development project, CLI/Docker/test prerequisites and explicit migration/test authorization. No CLI link was made. All nine migrations and 178 prepared pgTAP assertions remain unapplied/unexecuted. No records, migrations, deployments or other projects were touched. The owner's file-save confirmation was not interpreted as permission for database changes.

## Previous request — Supabase development preparation

**Preservation/repairs:** Retained all nine migration names/order and the exact original 81-assertion file; a normalized SHA-256 regression check guards preservation. Repaired known-unapplied draft 001's audit reason limit to 2,000 characters, matching existing approval/review records without truncation. Draft 006 now explicitly rejects unknown/malformed component classifications, including unsupported discounts. Draft 007's agency-review audit target now identifies the verification rather than the approval record; its API return value is unchanged. A new assertion guards that reference. No database has been changed.

**Confirmed discount scope:** Owner selected V1 discounted group tiers with mandatory fees and rejection of negative fees/unsupported discounts. No coupon, percentage-discount, stacking or billing model was added.

**Additional SQL tests:** `supabase/tests/0002_pricing_boundaries.test.sql` adds **97 assertions**, for **178 total**. Covers exact quantity/money/tier/date/sales/subscription/reconfirmation boundaries; closed/sold-out/on-request/unknown/insufficient/stale/future availability; Unicode/1,001/2,000/2,001-character review/audit behavior and atomic failure; moderation/reopening; both agency identities and role escalation/private access. Exact time tests use one outer statement rather than sleeps. Both files parse SQL/PL/pgSQL/probe syntax, but **0 pgTAP passed, 0 failed, 178 not run**. Parallel-session/API/ownership/query-plan verification remains outstanding.

**Development setup:** Added a secret-free local `supabase/config.toml` (PostgreSQL 17, distinct ports, disabled seeding/nonessential services), ignored CLI state/local target files, `dev-target.example.json`, offline target/preservation checks and guarded test-copy preparation. The configuration is TOML-parsed; CLI configuration acceptance is unverified because the CLI is absent. No Supabase initialization/start/login/link/config push or remote contact occurred. No dependency or application UI/brand changes were needed.

**Target safety:** No CLI project reference/branch, `.env.local` or development/production credential file or target environment variable was found. `npm.cmd run supabase:dev:check -- --unlinked` passes without connecting. `db:tests:prepare` correctly refuses an unconfigured target before creating `.temp` or copies. Offline planned/linked checks reject mismatched identifiers/URL, other project names and implicit target overrides without echoing values. Cloud project identity must still be checked in the dashboard; there is no selected production target here and no claim to have verified an unspecified remote project's purpose.

**Setup/checklist:** [SUPABASE_DEVELOPMENT_SETUP.md](SUPABASE_DEVELOPMENT_SETUP.md) records exact required Next.js public variables, optional CLI secrets, dedicated profile/workdir, development link, migration history/dry-run/apply, guarded CLI pgTAP execution and type-generation commands. All connecting/database commands are prepared only. The guide explains that local `config.toml` does not automatically configure hosted Auth/exposed schemas and that first `supabase start` can apply migrations.

**Local checks:** After all SQL repairs, `npm.cmd run check` passed formatting, lint with zero warnings, strict TypeScript, SQL/PL/pgSQL/function-body/dynamic-probe syntax checks, **109 unit/static-contract/target tests in seven files**, and the Next.js 16.3.8 production build. Python's standard TOML parser verified configuration syntax/key development settings. `git diff --check` and original test checksum verification passed. No browser rerun was needed for SQL/tooling/documentation changes; existing UI/brand source is unchanged. No runtime database result is claimed.

**Stop:** Wait for owner confirmation of the named empty Ghumne development project and permission for linking/migration application plus rolled-back synthetic tests. CLI/Docker/psql prerequisites remain missing. No production access, Mount Kailash changes, destructive data operation, migration execution, credential exposure or deployment occurred. See the updated [database review](DATABASE_IMPLEMENTATION_REVIEW.md).

## Previous request — dependency security and blocked local validation

**Phase A — targeted dependency remediation:** Reviewed all eight original high affected-package findings, their installed versions, advisory ranges and full paths. Three resolved through compatible patches: Next.js `16.3.6 -> 16.3.8`, sharp `0.35.4 -> 0.35.5`, source-map-js `1.2.1 -> 1.2.2`. Matched `eslint-config-next` / `@next/eslint-plugin-next` to `16.3.8`. Retained React, TypeScript, ESLint, Tailwind, Supabase and test-tool versions. Five inherited high findings remain in `eslint-config-next -> @next/eslint-plugin-next -> fast-glob -> micromatch -> braces@3.0.3`; no fixed braces release exists, and the inspected newer lint plugin retains the path. No forced fix, unsupported downgrade, vendored patch or audit suppression.

**Audit results:** `npm.cmd audit --json` exits 1 with 5 high/0 other-severity findings (previously 8 high); `npm.cmd audit --omit=dev --json` exits 0 with 0 vulnerabilities. `npm.cmd ls next eslint-config-next @next/eslint-plugin-next sharp source-map-js braces --all` confirms the patched resolutions. Detailed versions/paths/advisories and residual tooling risk are in [DEPENDENCY_SECURITY_REVIEW.md](DEPENDENCY_SECURITY_REVIEW.md).

**Post-patch quality gate:** `npm.cmd run check` passed formatting, lint (zero warnings), strict TypeScript, SQL/PL/pgSQL/function-body/dynamic-probe parsing for all nine migrations and the pgTAP file, **84 unit/static-contract tests in six files**, and the Next.js **16.3.8** production build. `npm.cmd run test:feedback:production` passed **1/1**; the patched production server served the homepage and hid `/ui-preview`, and temporary-server cleanup completed normally. `npm.cmd ls --depth=0` and `git diff --check` passed. TASK-015's six earlier development accessibility/responsive browser results remain preserved below; they were not rerun against the pre-existing old-framework dev process. No application UI or brand source changed.

**Phase B — blocked before database initialization:** `Get-Command supabase,docker,psql` found none on PATH. Docker CLI/Desktop paths under `C:\Program Files\Docker\Docker`, `C:\ProgramData\chocolatey\bin\supabase.exe` and `C:\Users\Acer\scoop\shims\supabase.exe` are absent. `supabase/config.toml` does not exist. No local stack/database was initialized, no installer or remote substitute was used and no database connection/migration/test runner was attempted. Per the owner's explicit missing-tools instruction, database execution stops here.

**Migration/pgTAP results:** **0/9 migrations executed; pgTAP 0 passed, 0 failed, 81 not run.** Reviewed the nine files' order, extension/Auth/owner dependencies and per-file transactions. Earlier committed files would survive a later failure; use inspected forward repair, not automatic replay/drop/reset. No destructive rollback is supplied. Static parsing cannot establish catalog resolution, live tenant isolation, role-escalation resistance, subscription enforcement, moderation, pricing correctness, query plans or races.

**Coverage and architectural issues:** The prepared corpus uses separate agency/traveler identities, but has not executed. Discount semantics are absent; negative fees cannot stand in for discounts. Exact traveler/tier/date/expiry/reconfirmation boundaries, closed/sold-out/insufficient/stale availability, complete moderation/reopening cases and concurrent transition tests need expansion and actual execution. Static inspection also found a reason-length mismatch: review records allow 2,000 characters while audit reasons allow 1,000, so a longer otherwise-valid review would roll back at audit insertion. This remains a concrete pre-application repair/test item; the SQL bundle was preserved at the missing-tools stop. Application auth, inquiry/retention controls, first-admin bootstrap and relevance matching remain future tasks. See [DATABASE_IMPLEMENTATION_REVIEW.md](DATABASE_IMPLEMENTATION_REVIEW.md) for inspection findings and the development-project readiness gate. TASK-129/130 are not marked complete.

**Environment note:** Installation succeeded with a Windows cleanup warning for the prior native compiler held by the existing dev server. That server was preserved; restart it to load the installed security patch. No recursive cleanup or unrelated process termination was used.

**Phase C:** Updated this log, database review, dependency security review and DEC-026/027. Readiness for a separate development Supabase project remains conditional on local execution/security coverage and a reviewed named remote target. Production migrations, deployment, destructive operations and billing remain outside this work.

## TASK-015 — Complete: feedback verification

**Review:** Existing feedback components/conventions were correct; no production component rebuild or unrelated UI change was necessary. Verified loading/status/skeleton semantics, heading choices, recovery actions, private error handling, public main landmarks and the global HTML shell.

**Tests added:** Six unit tests in `src/tests/unit/feedback.test.ts`; six browser tests in `src/tests/e2e/feedback.spec.ts`; one production smoke test in `feedback-production.spec.ts`. Added Playwright configuration and a cross-platform launcher. Tests verify reset callback wiring, Enter retry/focus, real home links, 44px targets, four viewport widths with normal/doubled text, reduced motion, runtime errors, axe results and production preview gating.

**Results:** `npm.cmd run test:feedback` passed all six tests. Zero axe violations on tested surfaces. Inspected mobile/desktop screenshots in ignored test-results. `npm.cmd run test:feedback:production` passed its one test after the required production build; the managed Windows sandbox required explicitly terminating only the verified temporary server on port 3126 to finish cleanup. The existing user dev server was left running. Unit tests, lint, strict types and production build pass through the full gate.

**Implementation issues resolved during verification:** Matched the accessibility helper's Playwright core types to version 1.63.0 and reused the existing localhost:3000 development server instead of starting a second Next dev process. No application security settings were weakened and no execution policy was changed.

## TASK-125 — Complete: provisional V1 policy baseline

Created [V1_BUSINESS_POLICIES.md](V1_BUSINESS_POLICIES.md) covering the owner's free registration/manual verification, moderation, 30-day reconfirmation, NPR/person/group prices, inquiry/WhatsApp/external links, configurable pilot/monthly/annual plans, preserved expiry data, Sponsored labels, relevance-first organic results and minimal/configurable retention. Single owner, manual renewal, Nepal calendar periods, no implicit grace, quota/downgrade behavior and technical abuse controls are explicitly engineering assumptions. Final commercial prices/limits, pilot duration, evidence/review/appeals, retention/consent/cleanup and sponsorship allocation are still open.

No real plan prices, agencies or inventory were invented. Pilot/monthly/annual examples in the SQL tests are conspicuously synthetic, guarded and rolled back if eventually run in an approved test database.

## Previous request — SQL drafts prepared; application not started

**Authoring:** Added nine transactional migrations for 45 public tables plus one private operation ledger, RLS/grants, composite tenant FKs, immutable plan/review/package history, licensed revision media metadata, safe integer pricing, nonoverlapping scopes, transactional quotas, 30-day reconfirmation, subscription-aware public projections, controlled operational RPCs, comparisons, safe shares, backend-only inquiries and minimal audit. Only operational configuration rows are seeded. No cascading agency-history deletion or destructive down/reset migration exists.

**Automated checks:** `npm.cmd run check` passed format, lint, strict types, SQL/procedure/dynamic-probe parsing, **84 tests in six unit files**, and production build. SQL checks never connect to a database. Eighteen database-contract tests check syntax, protection/grant coverage, safe function paths, public RPC allowlist, tenant scopes, integer money, eligibility and seed isolation. Six feedback unit tests supplement the original 60 tests. `npm.cmd ls --depth=0` passes.

**Deferred verification:** `supabase/tests/0001_marketplace.test.sql` contains 81 pgTAP assertions: synthetic admin, agencies A/B, travelers A/B; unauthorized role/tenant mutation; composite FK and price overlap; idempotency; moderation/quota; pilot/monthly/annual periods; whole-group pricing/unknown charges; confirmed versus unchecked dates; sponsored labeling; trip privacy/comparison/share/revocation; backend-only/rate-limited inquiries; stale reconfirmation; active-status time expiry and retained records. The file requires `ghumne.allow_test_fixtures=yes`, uses `.invalid` contacts and rolls back. It has not executed. Concurrent-session races and actual query plans still require an approved test target.

**Review/report:** [DATABASE_IMPLEMENTATION_REVIEW.md](DATABASE_IMPLEMENTATION_REVIEW.md) covers all eight requested report areas; [supabase/README.md](supabase/README.md) records migration order, prerequisites, first-admin bootstrap and approval gates. Updated master spec, architecture, decisions and README. No pretend generated database types were added.

**Privacy defaults:** Inquiry collection is disabled until explicitly enabled and its retention policy configured; no retention deletion worker, private Storage bucket, privileged application client or outbound messaging was created. Subscriptions expire by time-based eligibility without deleting data.

**Environment/security:** Added exact development-only `@playwright/test`, matching `playwright-core`, `@axe-core/playwright` and `@libpg-query/parser`. Runtime versions remain intact. Online audit findings affect Next.js/sharp and existing glob/source-map/lint dependencies; see report for advisories. No database client/CLI was used to connect or run SQL. No local environment file or paid service was created.

**Next:** Owner review of provisional policies and SQL bundle. Stop before database execution/destructive changes. TASK-129/130 are deliberately unfinished; actual Supabase RLS, function/catalog resolution and deployment readiness are not claimed.

## TASK-124 — Complete: earlier marketplace documentation reconciliation

**Audit:** Read the four planning records, original repository audit, README/design guidance, source/configuration, current routes, Supabase factories and test coverage; inspected worktree/history and tracked/hidden project files. No applicable AGENTS.md was found in checked workspace/ancestor paths. Starting worktree was clean at `ddb39d7`. That commit adds feedback/loading/error/not-found code but does not contain TASK-015's completion evidence. Its deployment title does not verify a live deployment.

**Findings:** Reuse the Next.js/TypeScript/Tailwind/Zod/Vitest foundation, environment safeguards, request-scoped clients, semantic UI, navigation/footer and feedback components. Preserve the empty database type boundary until actual schema generation. There are no application migrations or domain implementations to replace. The conflict was in the old plan: agencies were secondary, subscriptions/sponsorship were future-only, packages had one destination and a misleading price_from, and identity/approval/price/availability/tenant relationships were insufficient for marketplace matching.

**Changes:** Reframed the master specification around three core experiences; documented normalized destinations/origins, tenant membership, trusted role grants, versioned subscription entitlements, reviewed package revisions, structured itinerary, group price rules/fees, availability, secure inquiries, comparisons, labeled sponsorship and oversight. Added shared automatic package matching, total-group pricing, truthful alternatives, cache/expiry requirements and multi-tenant verification criteria. Updated architecture and DEC-015 through DEC-021; retained prior decisions as history and explicitly superseded the old direction. Updated the repository audit and README pointers.

**Task reconciliation:** Retained every TASK-001 through TASK-123 exactly once in the master task list, without renumbering or marking unstarted work complete. Added TASK-124 through TASK-145 for the audit and missing marketplace dependencies. TASK-015 remains in progress. The revised execution phases below replace the former numbered phase order, not historical completion logs.

| New phase                   | Work and dependencies                                                                                                                                                       | Prior task mapping                                                                  |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| A — Preserve/reconcile      | Retain completed foundation; finish feedback verification; resolve policy/schema contracts                                                                                  | 001-015 retained; 124 completed; 125 new                                            |
| B — Database/tenancy        | Draft identity, destinations, traveler and full marketplace schema with RLS/indexes/fixtures; approval before application; generate types and real database tests afterward | 016-022 resequenced; 087 moved from late partner phase; 126-130 new                 |
| C — Identity/access         | Auth/session proxy, traveler profile, route guards, admin authorization and agency membership                                                                               | 055-061 and 077 moved before protected operations; 131 new                          |
| D — Content/supply          | Admin destination operations, agency onboarding/approval, manual subscriptions, package revisions, pricing, availability and transactional publishing                       | 078-086, 088-089, 091-092 moved before public matching; 132-136 new                 |
| E — Public offers/inquiries | Destination UI, agency profile, eligible package detail/directory/comparison, external links and secure inquiry inbox                                                       | 023-035 resequenced with card before directory; 090, 094-100 moved forward; 137 new |
| F — Engines/search          | Budget engine first, Finder/scoring, shared package matching, automatic destination/search offers, alternatives and labeled sponsorship                                     | 048-054 before 036-047; 093 integrated here; 138-140/144 new                        |
| G — Saved plans             | Favorites and itinerary/save/share, then live package comparison                                                                                                            | 062-076 retained with dependencies; 141 new                                         |
| H — Measurement/SEO         | First-party events before aggregate lead analytics, plan-gated agency analytics and destination/agency/package SEO                                                          | 109-114 before 101; 102-108 retained; 143 new                                       |
| I — Acceptance/launch       | Cross-role marketplace E2E, real inventory verification or honest empty launch, quality audits, separately approved production work                                         | 115-123 retained/expanded; 142/145 new                                              |

**Dependency notes:** Build database drafts with policies/constraints as one review bundle, not exposed interim tables. Approve/application -> generated types and real RLS tests -> protected agency/admin operations. Publication needs agency approval + effective subscription + reviewed revision + quota. Public search release needs automatic matching on destination pages and Finder, not just package cards. Budget compatibility consumes tested price/estimate engines. Inquiry UI, storage and spam protection release together. Plan/package comparison consumes the same quote/match service. Test correctness with each service; numbered regression tasks do not defer it.

**Verification:** `npm.cmd run check` passed before documentation edits: formatting, lint, strict types, **60 tests in 4 files**, production build. PowerShell initially blocked the npm.ps1 shim; invoking npm.cmd ran the existing gate without changing execution policy. After edits, documentation formatting and `npm.cmd run format:check` passed, as did `git diff --check`. Canonical checklist validation confirmed all 145 task IDs exactly once, with only 001-014 and 124 complete and 015 still in progress. The final worktree contains only the six documented Markdown changes. No new tests are needed for this documentation-only change. No live Supabase check, migration, browser journey or deployment is claimed.

**Approval decisions:** Commercial plan names/fees/limits/terms/trials/grace and promotional allocation; expiry/downgrade visibility behavior; agency verification/review/freshness rules and single-owner initial scope; NPR/uniform-traveler/fixed-duration pricing scope; privacy/retention/consent; target database and actual migration application. These are concrete proposals in master section 12 and DEC-016 through DEC-021, not an approval request to build/apply anything now.

**Files modified:** `GHUMNE_MASTER_SPEC.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `PROGRESS.md`, `REPOSITORY_AUDIT.md`, `README.md`. No runtime source, test, dependency, environment or database files changed.

**Stop point:** Documentation/reporting complete. Future implementation resumes only on user instruction; no migrations, deletion or paid services are authorized by this plan.

## Historical implementation log

Entries below retain their original 2026-09-27 context and former task/phase references. The current state and revised master sequence above supersede their next-step instructions. Historical test/service statements are not new live verification.

## TASK-001 — Complete

**Understand:** Read the entire specification and inspect all existing project files and applicable instructions.

**Plan:** Inventory every requested subsystem, identify reusable work, and document the sequential foundation plan before coding.

**Implement:** Created `REPOSITORY_AUDIT.md`, `DECISIONS.md`, and this progress log. Updated TASK-001 status in the master specification. The original workspace contains only the specification; there is no application code or asset to reuse.

**Test:** Full file enumeration and local tool checks completed. Type checking, linting, builds, and application tests are unavailable at this baseline because there is no manifest or application. No runtime test is claimed as passed.

**Review:** No working functionality, secrets, data, or assets were changed. Initializing the missing application follows the specified architecture (DEC-007).

**Document:** Audit includes all requested areas, missing requirements, reuse findings, and the plan for TASK-002 through TASK-007.

**Files created:** `REPOSITORY_AUDIT.md`, `DECISIONS.md`, `PROGRESS.md`.

**Files modified:** `GHUMNE_MASTER_SPEC.md` (task status only).

**Environment/migrations:** No environment or database changes. Local Git initialization is needed for the specified commit workflow.

**Known issues/follow-up:** No existing test infrastructure. Supabase credentials and verified travel data will be needed at their respective tasks.

## TASK-002 — Complete

**Understand/plan:** Build only the framework foundation, using the empty-repository audit. Include minimal verification tooling needed to meet this task's quality gates.

**Implement:** Added Next.js App Router with a public route group, a root layout and basic metadata, strict TypeScript, npm scripts and lockfile, exact dependency versions, Node.js 24 configuration, and ignores for credentials/build output. No data access or interactive product features yet.

**Test:** `npm run typecheck`, `npm run lint`, `npm run build`, `npm ls --depth=0`, and `git diff --check` passed. Production server smoke checks passed: `/` returns HTTP 200 with English document, semantic main, product heading and responsive viewport; unknown route returns HTTP 404. The temporary server was stopped. npm reported zero known vulnerabilities during installation. No unit tests were added for static framework boilerplate.

**Review:** Independent read-only review found no concrete code, security, strictness, or scope issues. Peer-version warnings from the first dependency resolution were corrected before checks. No external fonts, credentials, or data required to build.

**Files created:** `.gitignore`, `.gitattributes`, `.npmrc`, `.nvmrc`, `package.json`, `package-lock.json`, `tsconfig.json`, `next-env.d.ts`, `next.config.ts`, `eslint.config.mjs`, `src/app/layout.tsx`, `src/app/(public)/page.tsx`, `README.md`.

**Files modified:** `GHUMNE_MASTER_SPEC.md`, `DECISIONS.md`, `PROGRESS.md`.

**Environment/migrations:** Local dependencies installed; local Git initialized. No database or deployment changes. No `.env.local` created.

**Known issues/follow-up:** ESLint 9 has an upstream deprecation warning but is the compatible version for Next.js's React lint plugin; tracked in DEC-008. The optional `unrs-resolver` postinstall remains unapproved; lint passed using the installed native optional package. Formatting belongs to TASK-004. Homepage product UI belongs to TASK-023.

## TASK-003 — Complete

**Understand/plan:** Configure the current Tailwind integration and global accessibility defaults without advancing the design-system task sequence.

**Implement:** Added Tailwind 4.3.3, its PostCSS plugin, and a root stylesheet. Applied bounded responsive spacing and type sizes to the existing minimal page. Added visible focus and reduced-motion defaults; no remote fonts or assets.

**Test:** Type checking, linting, production build, dependency check, production CSS retrieval, and whitespace checks passed. Headless Edge rendering reviewed at 390×844 and 1440×900. A temporary Playwright check passed at widths 320, 390, 768, and 1440: no horizontal overflow, expected responsive heading size, reduced-motion media preference recognized, and no browser runtime errors. Screenshots remain in ignored `test-results/`. Production test server stopped.

**Review:** Global stylesheet loads once from the root layout. Neutral base colors retain contrast. Existing content and semantics preserved. The direct Edge screenshot at mobile width clipped a wider browser viewport; repeated with Playwright's exact viewport emulation and verified the actual layout.

**Files created:** `postcss.config.mjs`, `src/app/globals.css`.

**Files modified:** `package.json`, `package-lock.json`, `src/app/layout.tsx`, `src/app/(public)/page.tsx`, `GHUMNE_MASTER_SPEC.md`, `DECISIONS.md`, `PROGRESS.md`.

**Environment/migrations:** Styling dependencies installed. Temporary Playwright CLI cached locally for browser verification, without adding it to application dependencies. No database or environment changes.

**Known issues/follow-up:** Product colors, type system, controls, and components remain in Phase 2. ESLint compatibility limitation from TASK-002 remains.

## TASK-004 — Complete

**Understand/plan:** Complete the quality tooling begun in TASK-002, preserving strict typing and keeping the specification's formatting intact.

**Implement:** Added Prettier, formatting scripts, editor defaults, lint auto-fix, and `npm run check` to run formatting, lint, types, and production build in order. Formatted the existing audit table and TypeScript config. Generated files, local configuration, caches, and the master specification are excluded from formatting.

**Test:** `npm run format` and `npm run check` passed. Negative stdin checks confirmed ESLint rejects explicit `any` and Prettier rejects unformatted code. A compiler probe using the project's TypeScript options rejects implicit `any` and null assigned to a string. An initial check incorrectly expected `tsc --showConfig` to expand every inherited strict flag; corrected by checking actual compiler diagnostics. `git diff --check` passed. No UI behavior changed, so TASK-003's browser checks remain applicable.

**Review:** Independent read-only tooling review found no concrete gaps. Commands stop on the first failure and do not suppress warnings. No broad lint disables or TypeScript exceptions added. Unit tests will join the gate when TASK-005 introduces validation logic.

**Files created:** `.editorconfig`, `.prettierrc.json`, `.prettierignore`.

**Files modified:** `package.json`, `package-lock.json`, `README.md`, `REPOSITORY_AUDIT.md` (formatting), `tsconfig.json` (formatting), `GHUMNE_MASTER_SPEC.md`, `PROGRESS.md`.

**Environment/migrations:** Installed development formatter only. No database, application environment, or production changes.

**Known issues/follow-up:** ESLint 9 compatibility limitation remains documented in DEC-008. Proceed to TASK-005.

## TASK-005 — Complete

**Understand/plan:** Provide a safe configuration template and validate only the service configuration needed next. Avoid reading or creating privileged credentials.

**Implement:** Added blank `.env.example`, typed Zod parsing, an explicit public environment accessor, and validation before bundling when configuration is supplied. Invalid diagnostics name fields without exposing values. Added Vitest and included tests in the quality gate. See DEC-010 for the modern key format and validation timing.

**Test:** `npm run check` passed: formatting, lint, strict types, all 40 environment tests, and production build with no Supabase configuration. A separate negative build check passed: a synthetic secret key in the public variable is rejected before compilation and is absent from diagnostics. Git ignore check confirms `.env.local` and `.env.production` are ignored while `.env.example` is trackable. `git diff --check` passed.

**Review:** Tests were implemented independently and reviewed against the validation contract. Tests cover valid/invalid URLs, loopback HTTP, key restrictions, missing/wrong types, removal of unrelated private fields, redacted errors, and lazy uncached reads. No actual secrets, external connections, or fake success paths.

**Files created:** `.env.example`, `src/lib/env/schema.ts`, `src/lib/env/public.ts`, `src/tests/unit/env.test.ts`, `vitest.config.mts`.

**Files modified:** `next.config.ts`, `tsconfig.json`, `package.json`, `package-lock.json`, `README.md`, `GHUMNE_MASTER_SPEC.md`, `DECISIONS.md`, `PROGRESS.md`.

**Environment/migrations:** Zod and Vitest installed. No `.env.local` or live credentials created; no database changes.

**Known issues/follow-up:** TASK-006 can be implemented and locally tested now, but live Supabase connectivity requires user configuration. ESLint compatibility limitation remains.

## TASK-006 — Complete (local client scope); live verification pending

**Understand/plan:** Configure the actual Supabase SSR SDK with explicit browser/server boundaries, typed access, cookie handling, and safe validation. Complete local implementation before requesting a live project check. Authentication UI, role guards, and database schema remain in their assigned phases.

**Implement:** Added browser and request-scoped server factories, a session refresh helper, and an empty typed database boundary that prevents queries to unimplemented tables. Server imports use `server-only`. Cookie writes are explicit; the proxy helper preserves session cookies and cache prevention headers across repeated writes. Added `npm run supabase:check` for a read-only Auth settings request with response validation, timeout, and no key/body logging. Configured ESM and explicit TS imports to reuse the environment parser directly from Node.js without a new runner.

**Test:** Final `npm run check` passed: formatting, lint, strict types, **60 tests in 4 files**, and the production build. Coverage: 40 environment tests, 9 client boundary/cookie tests, 5 proxy/session tests, and 6 connectivity-command regression tests. `npm ls --depth=0` and `git diff --check` passed. The actual connectivity command correctly exits with missing-configuration field names when `.env.local` is absent; **no live connection or auth flow has been verified**. No user credentials were read or invented.

**Review:** Independent review found and reproduced an HTTP 200 false-positive in the initial connectivity command. Fixed by validating JSON against the Auth settings response; regression tests reject HTML, unrelated JSON, invalid types, HTTP 401, and network failures. Final main-agent review removed warning suppression from the test subprocess and supplied its required `NODE_ENV=test`; all checks then passed. No concrete cookie isolation or cache-header findings remain.

**Files created:** `src/lib/supabase/client.ts`, `src/lib/supabase/server.ts`, `src/lib/supabase/proxy.ts`, `src/lib/supabase/database.types.ts`, `scripts/check-supabase.mjs`, `src/tests/unit/supabase-clients.test.ts`, `src/tests/unit/supabase-proxy.test.ts`, `src/tests/unit/supabase-check.test.ts`.

**Files modified:** `package.json`, `package-lock.json`, `next.config.ts`, `tsconfig.json`, `src/lib/env/public.ts`, `README.md`, `DECISIONS.md`, `GHUMNE_MASTER_SPEC.md`, `PROGRESS.md`.

**Environment/migrations:** Installed `@supabase/ssr`, `@supabase/supabase-js`, and `server-only`. No environment credentials created, remote project created, migrations applied, data changed, or deployment performed.

**External follow-up:** User must eventually set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` in root `.env.local` using `.env.example` for live integration. No secret or service-role key is required. The previous status treated the live check as a prerequisite for unrelated local tasks; the resume review corrected that overconstraint (DEC-012). No live integration is claimed as verified.

**Known issues/follow-up:** No routes consume Supabase yet. Wire `updateSupabaseSession` through Next.js's `src/proxy.ts` before enabling authenticated server rendering, by TASK-055 at the latest. Future Route Handlers must preserve SDK cache headers on their own responses. Replace the empty database boundary with migration-generated types during Phase 3. ESLint compatibility limitation in DEC-008 remains.

**Resume verification:** Re-read the full specification, progress log, implementation decisions, configuration, source, and tests. Working tree was clean. `npm run check` passed again: all 60 tests, format, lint, strict types, and production build. `npm ls --depth=0` and whitespace checks passed. No completed implementation needed rewriting.

**Next steps:** Proceed with TASK-007. Run the read-only live check once configuration is supplied, before claiming live data/auth integration works.

## TASK-007 — Complete

**Understand/plan:** Match specification section 5.3 while preserving existing source and client boundaries.

**Implement:** Established the remaining route, component, feature, library, and shared-type directories with `.gitkeep` markers. Added `ARCHITECTURE.md` with module responsibilities, dependency direction, server/browser boundaries, and rules for adding data access and protected routes. Existing `lib/env` and `tests/unit` are retained as justified refinements.

**Test/review:** `npm run check` passed (60 tests, formatting, lint, strict types, production build). Build still exposes only `/` and the built-in not-found route. Markers create no endpoints, UI, domain implementations, or dependencies. Existing imports and files remain in place.

**Files:** Created `ARCHITECTURE.md` and `.gitkeep` markers in the new directories listed there. Modified `README.md`, `GHUMNE_MASTER_SPEC.md`, `PROGRESS.md`, `DECISIONS.md`.

**Environment/migrations:** None. **Issues/blockers:** None for the design system. Live service verification remains pending. **Next:** TASK-008.

## TASK-008 — Complete

**Understand/plan:** Translate the specification's clean, mobile-first direction into shared semantic tokens; it defines no fixed brand palette.

**Implement:** Added `src/app/tokens.css` and `DESIGN_SYSTEM.md`. Updated `globals.css` to use background, text, and focus tokens. Added semantic status colors, decorative/control borders, 44px control sizing, spacing, radii, containers, and restrained elevation/motion values.

**Test/review:** `npm run check` passed (60 tests and all quality gates). One-off contrast calculation verified 19 intended pairings: normal text/status pairs exceed 4.5:1; focus/control boundaries exceed 3:1. Muted text has at least 5.87:1 contrast on supported surfaces. Production CSS check confirmed token emission and use by page/focus rules. No layout, content, or behavior changed. Soft borders are documented as decorative only.

**Files:** Created `src/app/tokens.css`, `DESIGN_SYSTEM.md`; modified `src/app/globals.css`, `GHUMNE_MASTER_SPEC.md`, `PROGRESS.md`, `DECISIONS.md`.

**Environment/migrations:** None. **Issues/blockers:** No local blocker. **Next:** TASK-009.

## TASK-009 — Complete

**Understand/plan:** Add readable, scalable typography without external font dependencies or fixed text heights.

**Implement:** Added system-font and display/title/heading/body/lead/caption tokens, semantic heading defaults, and supporting typography guidance. The existing minimal home page uses the shared display/lead roles and readable line length.

**Test/review:** Full quality gate passed (60 tests, types, lint, format, build). Headless Edge checked 320/390/768/1440px widths at 100% and 200% root text size: no overflow, one h1, correct font scaling, expected token background, no browser errors. Reviewed the mobile screenshot in ignored `test-results/typography-mobile.png`. No font download, new UI flow, or dependency introduced; temporary production server stopped.

**Files modified:** `src/app/tokens.css`, `src/app/globals.css`, `src/app/(public)/page.tsx`, `DESIGN_SYSTEM.md`, `GHUMNE_MASTER_SPEC.md`, `PROGRESS.md`.

**Environment/migrations:** None. **Issues/blockers:** None locally. **Next:** TASK-010.

## TASK-010 — Complete

**Understand/plan:** Build native buttons and navigation links using the shared tokens, preserving keyboard behavior and preventing accidental form submission.

**Implement:** Added `Button`, `ButtonLink`, `TextLink`, shared button styles, and a small class-name utility. Buttons default to non-submit, support four variants, and disable activation while loading. New-tab links preserve caller rel values and add noopener/noreferrer. Added a development-only component preview; it is not in product navigation.

**Test/review:** Full quality gate passed (60 tests and all other gates). Production `/ui-preview` returns HTTP 404. Browser checks passed for click vs submit semantics, keyboard activation and visible focus, disabled/loading states, link rel values, 44px targets, four viewport widths, and no runtime errors. Initial checks used 127.0.0.1 against a pre-existing localhost dev server, which blocked its dev resources; using its configured localhost origin resolved the interaction failure without changing application security settings. Existing user dev server remains running; only our production test server was stopped.

**Files created:** `src/components/ui/{button-styles.ts,button.tsx,link.tsx}`, `src/lib/utils/cn.ts`, `src/components/dev/ui-preview.tsx`, `src/app/(development)/ui-preview/page.tsx`. Removed the now-unneeded UI/utils directory markers. Updated `DESIGN_SYSTEM.md`, `ARCHITECTURE.md`, `GHUMNE_MASTER_SPEC.md`, `PROGRESS.md`.

**Environment/migrations:** None; no dependencies added. **Issues/blockers:** Live service follow-up remains. **Next:** TASK-011.

## TASK-011 — Complete

**Understand/plan:** Provide native, labeled form primitives with predictable keyboard behavior, help/error associations, and correct input types. Keep feature-specific server validation out of presentation.

**Implement:** Added shared field layout/feedback, `Input`, `Select`, `Textarea`, `Checkbox`, and `Radio`. Required IDs and visible labels link controls to hints/errors, preserve caller descriptions and native attributes/refs, and expose invalid/disabled states. Extended the development preview with inert examples.

**Test/review:** Full quality gate passed (60 tests and all gates). Headless Edge checks passed: required/email/min-value native validation, successful valid submission, selected values, error/hint IDs and aria-invalid, disabled fields, label-click checkboxes, radio arrow-key selection, vertical textarea resizing, 44px targets, four widths without overflow, and no runtime errors. Screenshot recorded in ignored `test-results/fields-mobile.png`. Native browser validation is documented as supplementary to future server-side Zod validation.

**Files created:** `src/components/ui/{field,input,select,textarea,choice}.tsx`. Modified `src/components/dev/ui-preview.tsx`, `DESIGN_SYSTEM.md`, `GHUMNE_MASTER_SPEC.md`, `PROGRESS.md`.

**Environment/migrations:** None; no dependencies added. **Issues/blockers:** None locally. **Next:** TASK-012.

## TASK-012 — Complete

**Understand/plan:** Provide presentation structure and labeled status tones without introducing destination data or business rules.

**Implement:** Added `Card`, header/content/footer parts, and text-required `Badge` with six tones. Cards support semantic article/section/div containers and explicit actions. Added preview examples and usage guidance.

**Test/review:** Full quality gate passed (60 tests and all gates). Browser checks passed for named article semantics, all six badge text/background contrast ratios (at least 4.5:1), noninteractive badges, and no overflow at four widths with normal/doubled text. Cards do not nest interactive elements or imply unverified travel status.

**Files created:** `src/components/ui/card.tsx`, `src/components/ui/badge.tsx`. Modified `src/components/dev/ui-preview.tsx`, `DESIGN_SYSTEM.md`, `GHUMNE_MASTER_SPEC.md`, `PROGRESS.md`.

**Environment/migrations:** None. **Issues/blockers:** None locally. **Next:** TASK-013.

## TASK-013 — Complete

**Understand/plan:** Add responsive, keyboard-accessible navigation while linking only to implemented destinations in the application.

**Implement:** Added brand/header/navigation components, a shared list of existing routes, and public route-group layout. Added a skip link with a focusable main target. Mobile disclosure closes on Escape, outside click, focus leaving, selection, route changes, or desktop resize; current-page links expose aria-current. Removed duplicate brand text from the minimal homepage. Preview navigation uses real in-page anchors to exercise multiple items without inventing product routes.

**Test/review:** Full quality gate passed (60 tests and all gates). Browser checks passed for skip-link focus, Tab navigation, Escape focus restoration, outside-click and link dismissal, breakpoint reset, active-page semantics, one banner/main, no overflow at four widths with doubled text, and no runtime errors. Mobile screenshot reviewed. Navigation does not expose unfinished routes, auth state, or fake actions.

**Files created:** `src/components/layout/{navigation.ts,brand-link.tsx,site-header.tsx,site-navigation.tsx}`, `src/app/(public)/layout.tsx`. Removed the layout marker. Modified the public home page, development preview page, `DESIGN_SYSTEM.md`, `GHUMNE_MASTER_SPEC.md`, `PROGRESS.md`.

**Environment/migrations:** None. **Issues/blockers:** More navigation items will be added only when their routes exist. **Next:** TASK-014.

## TASK-014 — Complete

**Understand/plan:** Add a compact semantic footer using established brand/navigation components and real routes.

**Implement:** Added Server Component `SiteFooter` and integrated it into the public layout and development preview. Includes positioning, copyright, shared brand, and separately labeled footer navigation. No fabricated contacts, policies, or partner links.

**Test/review:** Full quality gate passed (60 tests and all gates). Browser checks confirmed one contentinfo landmark, named footer navigation, working HTTP 200 links, no content overlap, and no overflow across four widths at normal/doubled text size. Footer stays after main content and uses the existing token system.

**Files created:** `src/components/layout/site-footer.tsx`. Modified public layout, preview page, `DESIGN_SYSTEM.md`, `GHUMNE_MASTER_SPEC.md`, `PROGRESS.md`.

**Environment/migrations:** None. **Issues/blockers:** Real policy/contact content must exist before adding its links. **Next:** TASK-015.
