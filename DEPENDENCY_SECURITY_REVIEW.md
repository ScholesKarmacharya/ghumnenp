# Dependency security review

Reviewed: 2026-10-20, Node 24.18.0 / npm 11.16.0. Scope: the eight high-severity affected-package findings present before this request. Counts below describe npm affected packages, not eight independent vulnerabilities.

## Findings and dependency paths

Paths start at `ghumne`. Versions in the paths are the original vulnerable installation. An ancestor finding inherits the root advisory; it is not an additional independent exploit.

| Affected package           | Vulnerable version / range reported                 | Original dependency path                                                                                                                                                                                              | Result                                                               |
| -------------------------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `next`                     | `16.3.6`; audit range `16.0.0–16.3.7`               | `ghumne -> next@16.3.6`                                                                                                                                                                                               | Patched to `16.3.8`                                                  |
| `sharp`                    | `0.35.4`; `<0.35.5`                                 | `ghumne -> next@16.3.6 -> sharp@0.35.4`                                                                                                                                                                               | Patched to `0.35.5` within Next's existing optional dependency range |
| `source-map-js`            | `1.2.1`; `>=1.0.0 <1.2.2`                           | `ghumne -> next@16.3.6 -> postcss@8.5.23 -> source-map-js@1.2.1`; also `ghumne -> postcss@8.5.28 -> source-map-js@1.2.1` and `ghumne -> @tailwindcss/postcss@4.3.3 -> @tailwindcss/node@4.3.3 -> source-map-js@1.2.1` | All deduplicated paths now resolve to `1.2.2`                        |
| `eslint-config-next`       | `16.3.6`; inherited audit range `>=14.3.0-canary.0` | `ghumne -> eslint-config-next@16.3.6`                                                                                                                                                                                 | Aligned to `16.3.8`; inherited braces finding remains                |
| `@next/eslint-plugin-next` | `16.3.6`; inherited audit range `>=14.3.0-canary.0` | `ghumne -> eslint-config-next@16.3.6 -> @next/eslint-plugin-next@16.3.6`                                                                                                                                              | Aligned transitively to `16.3.8`; inherited braces finding remains   |
| `fast-glob`                | `3.3.1`; inherited audit range `*`                  | `ghumne -> eslint-config-next@16.3.6 -> @next/eslint-plugin-next@16.3.6 -> fast-glob@3.3.1`                                                                                                                           | Unchanged; inherited braces finding remains                          |
| `micromatch`               | `4.0.8`; inherited audit range `>=0.2.0`            | `ghumne -> eslint-config-next@16.3.6 -> @next/eslint-plugin-next@16.3.6 -> fast-glob@3.3.1 -> micromatch@4.0.8`                                                                                                       | Unchanged; inherited braces finding remains                          |
| `braces`                   | `3.0.3`; advisory `<=3.0.3`                         | `ghumne -> eslint-config-next@16.3.6 -> @next/eslint-plugin-next@16.3.6 -> fast-glob@3.3.1 -> micromatch@4.0.8 -> braces@3.0.3`                                                                                       | Unresolved; no patched npm release available at review time          |

The high Next.js finding includes image-optimizer SSRF; the same installed package also carried moderate cache/SSG/metadata issues and a low development MCP exposure. `16.3.8` is the compatible patch boundary for the reported ranges, so a minor/major framework upgrade was unnecessary. Sources: [image optimizer](https://github.com/advisories/GHSA-cjq9-62q9-8jv4), [draft cache](https://github.com/advisories/GHSA-3w37-wq28-93x7), [SSG/ISR cache](https://github.com/advisories/GHSA-4jqv-mc3x-m676), [development MCP](https://github.com/advisories/GHSA-39w2-rjm5-chcv), [metadata images](https://github.com/advisories/GHSA-f87g-xv8r-7p7x), [SSG/ISR content](https://github.com/advisories/GHSA-mcj8-r9mp-w47p).

The sharp finding concerns bundled librsvg memory safety on affected Linux/glibc installations. Its relevance to a future deployment justified updating it even though this workstation is Windows. The source-map-js finding concerns denial of service when consuming malicious indexed source maps. Both now use their patched versions. Sources: [sharp advisory](https://github.com/advisories/GHSA-wq5f-xc86-pv6w), [source-map-js advisory](https://github.com/advisories/GHSA-68fv-2mgg-jv7q).

## Changes and unresolved risk

Used targeted `npm.cmd install next@16.3.8 --save-exact`, matching `eslint-config-next@16.3.8`, then `npm.cmd update sharp source-map-js --save=false`, with lifecycle scripts disabled. Exact security patches are recorded in the lockfile. React, TypeScript, Tailwind, Supabase clients, testing tools and ESLint versions remain unchanged. No forced audit fix, downgrade, package alias, vendored replacement, audit suppression or removed lint rule was used.

The five remaining high findings are one development-toolchain issue: deeply nested brace patterns can exhaust the stack. The [braces advisory](https://github.com/advisories/GHSA-vfj7-8cjw-p6xm) lists no patched version. Registry inspection confirmed `braces@3.0.3` and `micromatch@4.0.8` remain current, and both `@next/eslint-plugin-next@16.3.8` and `16.4.2` still depend on `fast-glob@3.3.1`. Upgrading the framework minor would not remove this chain. npm's proposed `eslint-config-next@14.2.35` downgrade is incompatible with the retained Next 16 stack and was rejected.

This is an unresolved lint/build-environment denial-of-service risk when tooling processes hostile patterns, not a finding in the installed production dependency set. Keep it tracked until upstream publishes a compatible fix, or separately review a supported lint-toolchain replacement with equivalent rules. A zero production audit does not resolve the full audit or certify application/database security. No acceptance of the residual risk on the owner's behalf is implied.

Windows reported an `EPERM` cleanup warning for the previous native SWC binary held by the pre-existing development server. Installation completed successfully and the active dependency path is patched. That existing server was preserved; restart it to load the new framework/compiler. No recursive cleanup or unrelated process termination was performed during installation.

## Verification

- `npm.cmd ls next eslint-config-next @next/eslint-plugin-next sharp source-map-js braces --all`: correct patched versions and the remaining lint-only braces path.
- `npm.cmd audit --json`: **5 high, 0 critical/moderate/low**, exit 1 for the documented unresolved findings; previously 8 high.
- `npm.cmd audit --omit=dev --json`: **0 vulnerabilities**, exit 0.
- `npm.cmd run check`: passed formatting, lint with zero warnings, strict TypeScript, static SQL/PL/pgSQL/function-body/probe checks, **84 tests in six files** and the Next.js **16.3.8** production build.
- `npm.cmd run test:feedback:production`: **1/1 passed** with normal temporary-server cleanup; homepage serves and development preview stays hidden.
- `npm.cmd ls --depth=0` and `git diff --check`: passed. Application UI/theme source was preserved. The earlier six development accessibility/responsive browser tests were not rerun against the old running dev process.

Audit results are a dated registry snapshot, not a promise about later disclosures. No database connection, production migration, deployment or billing activation is part of this remediation.
