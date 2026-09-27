# Ghumne

Nepal travel discovery and trip planning. Product scope and implementation order are defined in [GHUMNE_MASTER_SPEC.md](GHUMNE_MASTER_SPEC.md).

## Development

Use Node.js 24 and npm 11. The lockfile records the dependency versions.

```sh
npm ci
npm run dev
```

Open http://localhost:3000. The current page is the minimal framework foundation; product features follow the task sequence.

## Checks

```sh
npm run check
```

The quality gate checks formatting, lint, strict types, unit tests, and a production build, stopping at the first failure. Individual commands:

```sh
npm run format:check
npm run typecheck
npm run lint
npm test
npm run build
npm start
```

`typecheck` generates Next.js route types before running strict TypeScript checks. Lint is a separate required gate because Next.js builds do not run ESLint.

Use `npm run format` and `npm run lint:fix` to apply safe formatting/lint fixes, then rerun the checks. Formatting excludes the supplied specification, generated files, build/test output, and local environment files. Unit tests cover environment validation; browser and HTTP smoke checks are recorded in `PROGRESS.md`. Use `npm run test:watch` while working on tested logic.

## Environment

Copy `.env.example` to `.env.local` at the root when configuring Supabase. Fill in the project URL and its publishable key from the project's Connect dialog or API Keys settings. Public configuration is bundled into browser code; never paste a secret or service-role key into these variables. This new application accepts modern `sb_publishable_` keys and rejects legacy JWT keys. No privileged key is needed for ordinary session-based clients.

`src/lib/env/public.ts` reads only the two declared public values and validates them with Zod when called. Missing or invalid configuration raises an error containing field names, without echoing values. HTTPS is required except for loopback local development URLs. Unrelated static pages can build when both variables are absent. If either variable is supplied, Next.js validates both before bundling to catch incomplete configuration or a privileged key pasted into a public variable. Supabase features also validate when used. Restart local development after changes and rebuild deployments when public variables change.

Tests use inert fixtures and do not load `.env.local` or connect to a live project.

## Supabase clients

- `src/lib/supabase/client.ts`: browser client with SDK-managed cookie storage and browser singleton.
- `src/lib/supabase/server.ts`: a new client per request, reading the current Next.js cookie store. Server Components use the default read-only mode. Server Actions that mutate sessions must explicitly use `{ cookieAccess: "read-write" }`; unexpected write errors propagate.
- `src/lib/supabase/proxy.ts`: session refresh helper that verifies claims and forwards refreshed cookies to the downstream request and browser. It preserves the SDK's cache prevention headers across cookie writes.

There are no Supabase-consuming routes yet. The refresh helper must be wired through `src/proxy.ts` for those routes before enabling authenticated server rendering (TASK-055 at the latest). Future Route Handlers must forward session cookies and the SDK cache headers to their own response; the Server Action write mode alone does not handle response headers. This infrastructure does not authorize a user or role; feature-level server checks and RLS remain mandatory.

`database.types.ts` deliberately permits no application tables or RPCs until Phase 3 generates types from actual migrations. This prevents the SDK's untyped default from allowing arbitrary table access.

After setting `.env.local`, run:

```sh
npm run supabase:check
```

This performs one read-only request to Supabase Auth settings, validates the response shape, and prints no keys or response content. It checks connectivity and configuration; it does not test login, session refresh, database permissions, or RLS. Those require the later authentication and database tasks. Live verification is currently pending user configuration.

## Project records

- [Repository audit](REPOSITORY_AUDIT.md)
- [Source architecture](ARCHITECTURE.md)
- [Progress and validation results](PROGRESS.md)
- [Implementation decisions](DECISIONS.md)

Use Server Components by default. Keep domain logic outside presentation components. Do not commit local environment files or introduce privileged keys into browser code.
