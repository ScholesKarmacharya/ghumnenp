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

## Project records

- [Repository audit](REPOSITORY_AUDIT.md)
- [Progress and validation results](PROGRESS.md)
- [Implementation decisions](DECISIONS.md)

Use Server Components by default. Keep domain logic outside presentation components. Do not commit local environment files or introduce privileged keys into browser code.
