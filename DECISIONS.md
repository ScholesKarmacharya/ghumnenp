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
