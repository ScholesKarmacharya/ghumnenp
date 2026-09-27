# Application architecture

Ghumne is one Next.js App Router application. `GHUMNE_MASTER_SPEC.md` defines product scope; this document maps its modules to source folders.

## Module responsibilities

| Location                                                                    | Responsibility                                                                        |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `src/app/(public)`                                                          | Crawlable discovery and planning routes, composed from feature services and shared UI |
| `src/app/(auth)`                                                            | Authentication pages and callbacks when implemented                                   |
| `src/app/dashboard`, `src/app/admin`                                        | Traveler and admin routes; each must verify access server-side when introduced        |
| `src/app/api`                                                               | Route handlers for public/API interfaces and integrations                             |
| `src/components/ui`                                                         | Domain-independent accessible controls and presentation primitives                    |
| `src/components/layout`                                                     | Shared navigation, footer, and page layout                                            |
| `src/components/destination`, `trip`, `partner`                             | Presentation for those domains; accept typed data rather than querying services       |
| `src/features/{destinations,recommendations,trips,auth,agencies,inquiries}` | Domain services, validation and data access for each feature                          |
| `src/lib/supabase`                                                          | Central client creation, session infrastructure, and database types                   |
| `src/lib/env`                                                               | Explicit public configuration access and validation                                   |
| `src/lib/auth`                                                              | Shared server identity/authorization helpers when required                            |
| `src/lib/validation`                                                        | Validation reused across features; keep feature-specific schemas with the feature     |
| `src/lib/utils`                                                             | Small shared utilities with a concrete consumer                                       |
| `src/types`                                                                 | Shared domain contracts; keep local types near their implementation                   |
| `src/tests/unit`                                                            | Unit and isolated integration tests; later E2E tests live under `src/tests/e2e`       |
| `scripts`                                                                   | Local developer commands; no application request logic                                |

Empty directories are tracked with `.gitkeep`; they declare boundaries without creating routes or placeholder functionality. Remove a marker when adding the directory's first source file.

## Dependency direction

Routes compose presentation and call feature services. Presentation can import shared UI and domain types. Feature services can import shared libraries and their own validation. Shared libraries must not import application routes or presentation components. Do not use barrel files that mix server and browser exports.

Prefer Server Components. Put `"use client"` only at interactive entry points. Mark database access and privileged helpers with `server-only`; never pass a Supabase client, session, or privileged configuration to a presentation component. Server Actions remain thin: verify identity/authorization, validate input, call a service, and return a safe result.

## Data and future routes

Keep Supabase client construction in `lib/supabase`; feature data-access files import it instead of constructing their own clients. Domain calculations should be pure functions so budget and recommendation rules can be tested without UI or network access. Generate database types from the migrations during Phase 3.

Route groups do not change public URLs. Do not create placeholder pages merely to populate a directory or link to a route before it exists. A new authenticated route requires both verified server authorization and the Supabase session-refresh proxy; folder placement alone does not protect it.

Tests use inert fixtures by default. Tests against a real database must use an explicitly configured development/test project. Keep development seed data separate from production data.
