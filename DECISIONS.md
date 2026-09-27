# Implementation decisions

Product decisions DEC-001 through DEC-006 remain defined in `GHUMNE_MASTER_SPEC.md`. This file records implementation decisions permitted by that specification.

## DEC-007 — Initialize the missing application incrementally

Date: 2026-09-27. Related tasks: TASK-001, TASK-002.

The workspace initially contains only the master specification. Create the application manually in this directory to preserve it and keep each task reviewable. Use npm because it is already installed, with a committed lockfile and exact direct dependency versions. Initialize local Git history for the specification's task-by-task commit workflow; do not configure a remote or publish anything.

Follow the specified Next.js App Router modular monolith with `src/` and strict TypeScript. Keep the initial route limited to a product identity and message; implement the homepage experience in its assigned task. Add libraries when a task concretely needs them.

Current framework guidance: [Next.js installation](https://nextjs.org/docs/app/getting-started/installation). Verify package versions against the npm registry when installing.
