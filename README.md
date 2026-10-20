# Ghumne

Nepal travel discovery, multi-agency package marketplace and smart trip planning, developed by Zenlabs. Product scope and revised implementation order are defined in [GHUMNE_MASTER_SPEC.md](GHUMNE_MASTER_SPEC.md). The app now includes the approved Stitch homepage with editorial destination/itinerary previews and local trip-brief planning. The database foundation remains **unapplied SQL drafts**; live agency inventory, matching and authenticated marketplace operations are not enabled.

## Development

Use Node.js 24 and npm 11. The lockfile records the dependency versions.

```sh
npm ci
npm run dev
```

Open http://localhost:3000. Search filters destination previews and carries preferences to Trip Finder. Itinerary filters and trip-brief downloads work locally. Preview cards are not agency offers, quotes or availability.

## Checks

```sh
npm run check
```

The quality gate checks formatting, lint, strict types, SQL/procedure syntax, unit/static-contract tests and a production build, stopping at the first failure. It never executes migrations or opens a database connection. Individual commands:

```sh
npm run format:check
npm run typecheck
npm run lint
npm test
npm run db:check
npm run build
npm start
```

`typecheck` generates Next.js route types before running strict TypeScript checks. Lint is a separate required gate because Next.js builds do not run ESLint.

Use `npm run format` and `npm run lint:fix` to apply safe formatting/lint fixes, then rerun the checks. Formatting excludes the supplied specification, generated files, build/test output, and local environment files. Unit tests cover environment validation, SSR client/session boundaries, the read-only connectivity command, feedback semantics and database security contracts. Current and historical verification limits are recorded in `PROGRESS.md`. Use `npm run test:watch` while working on tested logic.

Feedback browser verification uses `npm run test:feedback` (development) and, after a successful build, `npm run test:feedback:production`. On Windows it uses installed Edge; elsewhere install a Playwright Chromium browser. The dev test reuses localhost:3000 when available, otherwise starts a server. Production uses temporary port 3126. In restricted Windows execution environments, helper process termination can require the corresponding process permission; stop only the verified test server. Browser checks do not access Supabase. In PowerShell, use `npm.cmd` if the npm.ps1 shim is blocked.

Homepage verification: run `npm run prepare:reference-qa` once to cache the original HTML's public Tailwind renderer/icon font for isolated reference screenshots, then `npm run build` and `npm run test:home`. The setup command uses public CDNs; the browser suite uses local assets and never queries Supabase. Screenshots are in ignored `test-results/homepage`. The supplied export is `supabase/stitch-reference/index.html` and is not served by the application. Original photos/font provenance and visual differences are documented in [HOMEPAGE_IMPLEMENTATION_REVIEW.md](HOMEPAGE_IMPLEMENTATION_REVIEW.md). `scripts/prepare-home-assets.mjs` explicitly refreshes source assets; builds do not run it or require network access. No dependencies were added for this homepage.

## Database preparation

Read [V1 business policies](V1_BUSINESS_POLICIES.md), [database implementation review](DATABASE_IMPLEMENTATION_REVIEW.md) and the [cloud-only workflow](SUPABASE_DEVELOPMENT_SETUP.md). Nine review migrations and two guarded pgTAP suites (206 prepared assertions) exist. No migration or pgTAP assertion has executed. Development uses the dedicated hosted Ghumne Supabase project with no Docker/WSL/Linux. An isolated 001-only workdir is prepared for first-migration review; CLI linking, catalog/history preflight and explicit approval remain pending. Static parsing does not verify runtime security; hosted tests and generated types follow approved application. Production is separately approved.

No agency/package or commercial plan data is seeded. Inquiry collection defaults off, retention periods are unconfigured, and no payment/billing, Storage upload or retention deletion worker is installed. Dependency security findings and remaining commercial choices are recorded in the review; address them before deployment.

## Environment

Copy `.env.example` to `.env.local` at the root when configuring Supabase. Fill in the project URL and its publishable key from the project's Connect dialog or API Keys settings. Public configuration is bundled into browser code; never paste a secret or service-role key into these variables. This new application accepts modern `sb_publishable_` keys and rejects legacy JWT keys. No privileged key is needed for ordinary session-based clients.

`src/lib/env/public.ts` reads only the two declared public values and validates them with Zod when called. Missing or invalid configuration raises an error containing field names, without echoing values. HTTPS is required except for loopback local development URLs. Unrelated static pages can build when both variables are absent. If either variable is supplied, Next.js validates both before bundling to catch incomplete configuration or a privileged key pasted into a public variable. Supabase features also validate when used. Restart local development after changes and rebuild deployments when public variables change.

Tests use inert fixtures and do not load `.env.local` or connect to a live project.

## Supabase clients

- `src/lib/supabase/client.ts`: browser client with SDK-managed cookie storage and browser singleton.
- `src/lib/supabase/server.ts`: a new client per request, reading the current Next.js cookie store. Server Components use the default read-only mode. Server Actions that mutate sessions must explicitly use `{ cookieAccess: "read-write" }`; unexpected write errors propagate.
- `src/lib/supabase/proxy.ts`: session refresh helper that verifies claims and forwards refreshed cookies to the downstream request and browser. It preserves the SDK's cache prevention headers across cookie writes.

There are no Supabase-consuming routes yet. The refresh helper must be wired through `src/proxy.ts` for those routes before enabling authenticated server rendering (TASK-055 at the latest). Future Route Handlers must forward session cookies and the SDK cache headers to their own response; the Server Action write mode alone does not handle response headers. This infrastructure does not authorize a user or role; feature-level server checks and RLS remain mandatory.

`database.types.ts` deliberately permits no application tables or RPCs until revised Phase B generates types from the approved actual schema. This prevents the SDK's untyped default from allowing arbitrary table access. Database migrations must not be applied, data deleted or paid services introduced without explicit approval. The documentation plan itself grants no such approval.

After setting `.env.local`, run:

```sh
npm run supabase:check
```

This performs one read-only request to Supabase Auth settings, validates the response shape, and prints no keys or response content. It checks connectivity and configuration; it does not test login, session refresh, database permissions, or RLS. The configured owner-identified Ghumne host/key passes this check; database/security execution remains pending.

## Project records

- [Supabase development setup and confirmation checklist](SUPABASE_DEVELOPMENT_SETUP.md)
- [Database implementation review](DATABASE_IMPLEMENTATION_REVIEW.md)
- [Repository audit](REPOSITORY_AUDIT.md)
- [Source architecture](ARCHITECTURE.md)
- [Progress and validation results](PROGRESS.md)
- [Implementation decisions](DECISIONS.md)

Use Server Components by default. Keep domain logic outside presentation components. Do not commit local environment files or introduce privileged keys into browser code.
