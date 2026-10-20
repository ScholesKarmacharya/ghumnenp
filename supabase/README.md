# Ghumne database review bundle

**Hosted Supabase Cloud only. No Docker, WSL, Linux, local database, deployment or billing.** These nine SQL files are unapplied review drafts targeting Supabase PostgreSQL 17+. No migration/test runner is wired into npm checks, builds or deployment.

Read the [cloud workflow and first-migration approval steps](../SUPABASE_DEVELOPMENT_SETUP.md), [implementation review](../DATABASE_IMPLEMENTATION_REVIEW.md), [complete RLS inventory](RLS_REVIEW.md) and [V1 policies](../V1_BUSINESS_POLICIES.md).

## Preserved dependency order

| Order | File                                    | Dependency/content                                                                                     |
| ----- | --------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| 001   | 202610200001_identity.sql               | Auth profiles/roles, private helpers, settings/retention and audit; 2,000-character audit reasons      |
| 002   | 202610200002_agencies_subscriptions.sql | Identity-dependent tenancy/verification/approval and versioned subscriptions; btree_gist in extensions |
| 003   | 202610200003_destinations.sql           | Identity/admin-dependent location/destination knowledge                                                |
| 004   | 202610200004_packages.sql               | Agency/destination-dependent revision/itinerary/pricing/availability tables and tenant FKs             |
| 005   | 202610200005_travelers_marketplace.sql  | Profiles/packages-dependent trips/shares/comparisons/inquiries/placements/events                       |
| 006   | 202610200006_pricing_visibility.sql     | Eligibility and integer group quote functions over 001–005                                             |
| 007   | 202610200007_workflows.sql              | Private idempotency ledger and authorized review/subscription/publication transitions                  |
| 008   | 202610200008_catalog_operations.sql     | Ledger/eligibility-dependent safe public catalog and operational RPCs                                  |
| 009   | 202610200009_integrity_controls.sql     | Final constraints/triggers and role/lifecycle controls over prior objects                              |

All nine names/order are preserved. No file was added, removed, renamed, squashed or applied. Full stored approval/review reasons in 002/004 now share 001's 2,000-character audit limit, including surrounding spaces; blank reasons fail and text is never truncated. Existing unsupported-discount rejection in 006 and corrected verification audit target in 007 are preserved. If an already-applied environment is discovered, inspect history and prepare forward changes instead of rewriting applied history.

## Safe hosted application

The owner identifies project `enyfguwoqhcprqeuhain` as dedicated Ghumne development; its configured host/key passes a read-only Auth check. The ignored allowlist pins this reference. CLI installation/link and independent dashboard/catalog/history inspection remain pending. Never infer project identity from a database named postgres or a local config label.

`npm.cmd run db:first:prepare` creates an ignored, fingerprinted workdir containing **001 only**. Linked checks and a one-file dry run precede owner approval. Ordinary db push in the full checkout would apply all pending files; do not use it for a 001-only approval. The exact native Windows login/link/dry-run/apply commands are in the cloud guide. No application command was executed.

Each file has its own transaction. A later failure leaves earlier migrations committed; inspect the prefix and repair forward. There is no destructive down/reset workflow. Review hosted Auth roles, PostgreSQL version, migration ownership, empty/conflicting schemas, extension schema and exposed schemas using [read-only preflight SQL](preflight/hosted-read-only.sql). Never relocate extensions automatically. Real first-admin creation is a separate reviewed action, not a fixture seed.

## Prepared pgTAP — zero execution results

- 0001_marketplace.test.sql: original **81 assertions**, unchanged. LF-normalized SHA-256: `90d178d90e90a2404239864f6f555adaa08027eaecee7304eb4c975ba516c09a`.
- 0002_pricing_boundaries.test.sql: **125 assertions**, including 28 added in cloud preparation.
- **206 total: 0 executed, no passing/failing runtime result.**

After all nine migrations and synthetic fixture writes are separately approved, run the whole guarded copies against this isolated hosted development database through its SQL Editor or optional native Windows psql. No Docker/WSL/Linux is required. Do not use the CLI's containerized test db runner.

`npm.cmd run db:tests:prepare -- --planned` (or --linked after the main checkout is linked) checks the target and creates ignored copies only. Copies use transaction-local fixture opt-in/timeouts, fixed assertion plans, finish(true) to raise SQL errors on failed assertions/incomplete plans, rollback and a completion marker. Originals remain guarded and unchanged except the intentionally expanded second suite. SQL Editor must execute each complete copy; native psql uses ON_ERROR_STOP and TLS/password prompts. See the cloud guide for exact steps and result criteria. Never run fixtures on production or a project containing real users/data.

## Security assumptions and outstanding gates

All 46 tables enable RLS and revoke API defaults. All 54 policies, tenant FKs, restricted column grants and definer actor checks have been inspected. Anon reads only curated projections; private tables/helpers are not general endpoints. The trusted migration/definer owner bypasses ordinary RLS; actual hosted ownership/grants/schema exposure must be inspected after application.

Inquiry collection defaults disabled. No Storage upload policy, retention worker, automatic billing, payment integration, real listing seed or outbound messaging is installed. A future trusted inquiry endpoint must validate identity/contact/consent/origin and derive a secret-HMAC abuse key. Share tokens need cryptographic randomness; only hashes are stored. Expiry hides eligibility without deleting agency history/inquiries.

`npm.cmd run db:check` parses SQL/PL/pgSQL/probes/preflight offline without connecting. **Syntax/static contracts do not verify deployed security.** Hosted pgTAP, real API/Auth identities, ownership/grants, concurrent transitions and query plans remain required. No other Supabase project was accessed or changed.
