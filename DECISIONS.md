# Implementation decisions

Product decisions DEC-001 through DEC-006 remain defined in `GHUMNE_MASTER_SPEC.md`. This file records implementation decisions permitted by that specification.

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
