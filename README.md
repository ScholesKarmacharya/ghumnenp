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

The quality gate checks formatting, lint, strict types, and a production build, stopping at the first failure. Individual commands:

```sh
npm run format:check
npm run typecheck
npm run lint
npm run build
npm start
```

`typecheck` generates Next.js route types before running strict TypeScript checks. Lint is a separate required gate because Next.js builds do not run ESLint.

Use `npm run format` and `npm run lint:fix` to apply safe formatting/lint fixes, then rerun the checks. Formatting excludes the supplied specification, generated files, build/test output, and local environment files. Add focused automated tests when implementation introduces testable business or validation logic; the current static foundation has browser and HTTP smoke validation recorded in `PROGRESS.md`.

## Project records

- [Repository audit](REPOSITORY_AUDIT.md)
- [Progress and validation results](PROGRESS.md)
- [Implementation decisions](DECISIONS.md)

Use Server Components by default. Keep domain logic outside presentation components. Do not commit local environment files or introduce privileged keys into browser code.
