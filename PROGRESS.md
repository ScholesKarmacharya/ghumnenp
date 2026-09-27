# Ghumne implementation progress

Updated: 2026-09-27.

## Current state

- Completed: TASK-001 through TASK-014.
- Current task: TASK-015 — Standard loading/error/empty states.
- Next task: TASK-016 — Initial schema migration.
- Blockers: none for local architecture/design work. Live Supabase verification remains pending project configuration; it is required before live integration, not for unrelated local work.
- Source of truth: `GHUMNE_MASTER_SPEC.md`.

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
