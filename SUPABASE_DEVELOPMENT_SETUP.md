# Ghumne hosted development workflow

Updated 2026-10-20. **Supabase Cloud only. No Docker, WSL, Linux, local stack, deployment or billing. No migrations or pgTAP assertions have executed.** Current authorization covers local preparation and read-only verification. Stop before the first hosted migration.

## Target and evidence

The owner confirms the existing dedicated Ghumne project is the development target. Its reference is `enyfguwoqhcprqeuhain`; the configured URL is `https://enyfguwoqhcprqeuhain.supabase.co`. The keyed, redirect-disabled Auth settings check succeeded again on 2026-10-20, without printing credentials or response contents. No other project was contacted.

The ignored `supabase/dev-target.local.json` pins this reference with the local label `ghumne-development`. That label is a convention, not proof of the dashboard name. No browser session or Management API credential was available to independently inspect the organization, database version, schema emptiness or migration history. Verify these in the [exact Ghumne dashboard](https://supabase.com/dashboard/project/enyfguwoqhcprqeuhain) before approval. Do not open other projects.

The app connection is **not a CLI link**. No CLI link exists here. Supabase CLI was not found on PATH, in project dependencies/bin, or in inspected Chocolatey/Scoop locations. Native psql/pg_prove were not found. No tools were installed. Docker is not a prerequisite for this workflow.

## Reviewed bundle

All nine originals remain in their original 001–009 order; see [migration list](supabase/README.md). All 54 policies across 46 tables were inspected; see [RLS review](supabase/RLS_REVIEW.md). Syntax checks cannot certify database security.

Draft 001 already permits 2,000-character audit reasons. Drafts 002/004 now limit the **complete stored** approval/review reason to 2,000 characters including spaces, matching audit/verification notes, while rejecting blank reasons. There is no truncation. The existing classification repair in 006 and verification audit-reference repair in 007 are preserved.

There are **206 prepared pgTAP assertions**: 81 original, unchanged, plus 125 boundary/security assertions. Discounts remain reviewed V1 group tiers; no coupon, percentage, stacking or payment model was added. Original suite LF-normalized SHA-256: `90d178d90e90a2404239864f6f555adaa08027eaecee7304eb4c975ba516c09a`.

The CLI configuration file does not start a stack or push hosted configuration. Seeding is disabled; linking does not configure hosted Auth or exposed schemas. CLI configuration acceptance remains pending installation.

## 1. Offline preparation — completed

```powershell
Set-Location -LiteralPath 'C:\Users\Acer\Desktop\CODE\GhumneAd'
npm.cmd run supabase:dev:check -- --planned
if ($LASTEXITCODE -ne 0) { throw 'Review the Ghumne target.' }
npm.cmd run db:first:prepare
if ($LASTEXITCODE -ne 0) { throw 'Snapshot preparation failed.' }
npm.cmd run db:first:check -- --check-planned
if ($LASTEXITCODE -ne 0) { throw 'Snapshot changed.' }
```

The preparer copies **only 202610200001_identity.sql**, CLI configuration and the nonsecret allowlist into ignored `test-results/ghumne-first-migration`. Its manifest fingerprints configuration and all nine source migrations. No environment file or credential is copied. Checks reject extra migrations, changed snapshots/source/configuration, mismatched links, branch targeting and implicit database/workdir overrides. Existing files are not overwritten automatically. No CLI/database client is invoked.

Ordinary `db push --linked` applies **all pending migrations** in its workdir. This isolated one-file workdir makes approval of 001 precise while preserving all nine originals.

## 2. Native Windows CLI and link — pending

Prepared commands only. The [official CLI installation](https://supabase.com/docs/guides/local-development/cli/getting-started) supports a project dependency; no database server or container runtime is required for login/link/push.

```powershell
npm.cmd install --save-dev --save-exact supabase
if ($LASTEXITCODE -ne 0) { throw 'CLI installation failed.' }
npx.cmd --no-install supabase --version
if ($LASTEXITCODE -ne 0) { throw 'CLI unavailable.' }
```

Record the resolved version, inspect package/lockfile changes and command help. Do not start a local stack or use reset, local diff/dump or the CLI test runner.

```powershell
$ghumneFirstWorkdir = 'C:\Users\Acer\Desktop\CODE\GhumneAd\test-results\ghumne-first-migration'
npm.cmd run db:first:check -- --check-planned
if ($LASTEXITCODE -ne 0) { throw 'Unreviewed target/snapshot.' }
npx.cmd --no-install supabase --profile ghumne-development --workdir $ghumneFirstWorkdir login
if ($LASTEXITCODE -ne 0) { throw 'Login failed.' }
npx.cmd --no-install supabase --profile ghumne-development --workdir $ghumneFirstWorkdir link --project-ref enyfguwoqhcprqeuhain
if ($LASTEXITCODE -ne 0) { throw 'Ghumne link failed.' }
npm.cmd run db:first:check -- --check-linked
if ($LASTEXITCODE -ne 0) { throw 'CLI link differs from reviewed target.' }
```

Use private CLI prompts or protected secret handling. Never put passwords/tokens in command arguments, chat or logs. Keep existing .env.local intact and ignored. The public app key cannot perform CLI login/database administration. The CLI may store credentials in its credential store; the staged bundle contains none. See [login/link reference](https://supabase.com/docs/reference/cli/supabase-link).

If a link exists, inspect it with the linked check; do not unlink/replace it automatically. Do not enumerate projects or operate in other checkouts. A profile selects credentials; the explicit project reference, workdir and guard constrain the target.

## 3. Hosted preflight and one-file plan — pending

In that exact dashboard, verify name, organization, reference and development purpose. Review hosted API exposed schemas: **private must remain unexposed**. Run [hosted-read-only.sql](supabase/preflight/hosted-read-only.sql) in its SQL Editor. These catalog queries use a read-only transaction and rollback. Expect PostgreSQL 17+, Supabase Auth/API roles, a trusted migration owner, no private schema and no pre-existing application relations in public/private. Review extension availability; an existing btree_gist must be in extensions. Do not relocate extensions or modify conflicts automatically. A database named postgres does not prove project identity.

```powershell
npm.cmd run db:first:check -- --check-linked
if ($LASTEXITCODE -ne 0) { throw 'Wrong/changed Ghumne target.' }
npx.cmd --no-install supabase --profile ghumne-development --workdir $ghumneFirstWorkdir migration list --linked
if ($LASTEXITCODE -ne 0) { throw 'History inspection failed.' }
npx.cmd --no-install supabase --profile ghumne-development --workdir $ghumneFirstWorkdir db push --linked --dry-run
if ($LASTEXITCODE -ne 0) { throw 'First-file plan failed.' }
```

Stop on unexpected history or existing Ghumne objects. The dry run must list **only 202610200001_identity.sql**. It does not execute application SQL or prove runtime success. No CLI operation above has run here. See [push/dry-run reference](https://supabase.com/docs/reference/cli/supabase-db-push).

## 4. Exact first-migration approval boundary

Review preflight/history/dry-run results, [migration 001](supabase/migrations/202610200001_identity.sql) and its staged manifest/hash. Migration 001 creates the private helper schema, five public identity/settings/audit tables, RLS/grants/functions, configuration rows and one auth.users signup trigger. It commits independently, does not backfill existing Auth users, and creates no paid plan or billing integration.

Prepared migration 001 SHA-256: `d144d34a2dc6187384bfbd52cb280e10480a6b92de2b27eda0544addb8f044c1`. Any source/configuration change invalidates the current snapshot and requires renewed review.

Suggested approval **after the preflight passes**:

> I approve applying only 202610200001_identity.sql, matching the reviewed SHA-256 manifest, to Ghumne development project enyfguwoqhcprqeuhain. Do not apply 002–009, run fixture tests, deploy, activate billing or access any other project. Stop after 001 and report its result.

**Not executed. Only after that approval**, recheck the snapshot/link and the same one-file dry run, then:

```powershell
npm.cmd run db:first:check -- --check-linked
if ($LASTEXITCODE -ne 0) { throw 'Approval snapshot/target changed.' }
npx.cmd --no-install supabase --profile ghumne-development --workdir $ghumneFirstWorkdir db push --linked
if ($LASTEXITCODE -ne 0) { throw 'Stop and inspect the transaction/history.' }
npx.cmd --no-install supabase --profile ghumne-development --workdir $ghumneFirstWorkdir migration list --linked
if ($LASTEXITCODE -ne 0) { throw 'Could not verify history.' }
```

Confirm history records only 001, inspect its objects/policies/owners, record the actual result and stop. **The full pgTAP suites require all nine migrations and cannot run against 001 alone.** No further migration or fixture test is implicitly authorized.

A later separately reviewed approval may link the original full checkout to the **same reference**, inspect history (001 already applied), dry-run and apply the remaining eight. Never use reset, automatic history repair, role/seed inclusion or --include-all. Failure in a later file leaves an earlier committed prefix; inspect it and prepare a forward repair. Do not replay the whole bundle or drop schemas.

## 5. Hosted pgTAP without Docker — execution requires future approval

After all nine migrations are explicitly approved/applied and synthetic test writes are separately approved, prepare fresh copies:

```powershell
# Main checkout unlinked: use --planned. If linked to this project: use --linked.
npm.cmd run db:tests:prepare -- --planned
if ($LASTEXITCODE -ne 0) { throw 'Test preparation failed.' }
```

Preparation is local and can run now. Copies in `supabase/.temp/ghumne-tests` make fixture opt-in transaction-local, bound statement/lock waits, replace no_plan() with fixed 81/125-assertion plans, and use **finish(true)** to turn failed assertions/incomplete plans into SQL errors. A completion marker follows rollback. Source suites remain untouched. See [pgTAP finish semantics](https://pgtap.org/documentation.html).

**No-install route: hosted SQL Editor.** Open only the exact Ghumne project, inspect pgTAP schema/version and finish(boolean) availability, and execute one **entire generated file** at a time as the trusted test operator. Do not select individual statements. Tests enable pgTAP in extensions if needed inside their rolled-back transaction, together with synthetic Auth/agency/package fixtures; no persistent extension enablement is required by these scripts. Require the final 81/125 completion marker and no prior error. An unavailable finish(boolean) is a blocker; do not weaken failure checking. Record actual output. Close/roll back an interrupted session. Never promote fixture identities to real administrators.

**Repeatable route: native Windows psql client.** Optional Windows PostgreSQL client tools require no Linux, server or Perl runner. Obtain host, root certificate and user only from this project's Connect panel. Use a direct connection where available or the **session pooler**, with user postgres.enyfguwoqhcprqeuhain. Avoid the transaction pooler because tests switch roles and use transaction/session state. Validate TLS; prompt for the password. See [Supabase psql/SSL instructions](https://supabase.com/docs/guides/database/psql).

```powershell
# No password in this variable. Supply Ghumne's exact host/certificate privately.
$ghumneDevConnection = 'host=<GHUMNE_SESSION_POOLER_HOST> port=5432 dbname=postgres user=postgres.enyfguwoqhcprqeuhain sslmode=verify-full sslrootcert=<GHUMNE_ROOT_CERTIFICATE_PATH>'
psql -X -W --set=ON_ERROR_STOP=1 --no-align --tuples-only --quiet --dbname $ghumneDevConnection --file supabase/.temp/ghumne-tests/0001_marketplace.test.sql --output test-results/0001-marketplace.tap
if ($LASTEXITCODE -ne 0) { throw 'Marketplace SQL/pgTAP failed.' }
psql -X -W --set=ON_ERROR_STOP=1 --no-align --tuples-only --quiet --dbname $ghumneDevConnection --file supabase/.temp/ghumne-tests/0002_pricing_boundaries.test.sql --output test-results/0002-pricing-boundaries.tap
if ($LASTEXITCODE -ne 0) { throw 'Boundary SQL/pgTAP failed.' }
```

Revalidate allowlist/link and actual host/user before execution. Require complete plans, 206 passing assertion lines, no not-ok/bailout/SQL errors, both rollback markers and zero exit status. ON_ERROR_STOP combined with generated finish(true) makes failed assertions fatal; plain psql success against the original finish() suites is insufficient. See [psql error handling](https://www.postgresql.org/docs/current/app-psql.html).

**Do not use supabase test db --linked**: it still invokes containerized pg_prove, as the [CLI test reference](https://supabase.com/docs/reference/cli/supabase-test-db) explains. Both alternatives execute inside the hosted database without Docker/WSL/Linux.

## Security limits and project isolation

**Database security remains runtime-unverified.** Execute the role/JWT-claim suites, inspect actual owners/grants/exposed schemas, then test real API identities, concurrent moderation/publication/quota/subscription operations and query plans. Privileged SQL Editor reads alone do not certify RLS. The suites switch into anon/authenticated/service roles; real API/session integration is still separate.

The migration files contain no second-project connection, remote database URL, FDW/dblink/network call, schema reset or billing action. Their effects stay in the PostgreSQL database selected by the connection; SQL cannot recognize a wrong project by itself. Pinned reference, isolated workdir, linked guards and reviewed history/plan keep that selection explicit. No other project, including Mount Kailash, was accessed.

**Stop: local preparation complete; 0/9 migrations executed; 206 pgTAP assertions not run.** CLI installation/link, independent dashboard/catalog/history checks and the one-file dry run remain pending before approval.
