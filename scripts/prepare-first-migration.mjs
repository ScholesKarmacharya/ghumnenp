// Local files only. This script cannot log in, link, connect, or apply SQL.
import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { checkDevTarget } from "./lib/dev-target.ts";
import {
  migrationHash as hash,
  verifyFirstMigrationCopy,
} from "./lib/first-migration.ts";

const root = new URL("../", import.meta.url);
const stage = new URL("test-results/ghumne-first-migration/", root);
const first = "202610200001_identity.sql";
const expectedNames = [
  first,
  "202610200002_agencies_subscriptions.sql",
  "202610200003_destinations.sql",
  "202610200004_packages.sql",
  "202610200005_travelers_marketplace.sql",
  "202610200006_pricing_visibility.sql",
  "202610200007_workflows.sql",
  "202610200008_catalog_operations.sql",
  "202610200009_integrity_controls.sql",
];
async function run(mode) {
  if (!["--prepare", "--check-planned", "--check-linked"].includes(mode))
    throw new Error("Choose --prepare, --check-planned or --check-linked.");
  await checkDevTarget("planned");
  const sourceDir = new URL("supabase/migrations/", root);
  const names = (await readdir(sourceDir)).sort();
  if (JSON.stringify(names) !== JSON.stringify(expectedNames))
    throw new Error("Review the exact nine migration filenames and order.");
  const migrations = {};
  for (const name of names)
    migrations[name] = hash(await readFile(new URL(name, sourceDir)));
  const config = await readFile(new URL("supabase/config.toml", root));
  const target = await readFile(
    new URL("supabase/dev-target.local.json", root),
  );
  const source = await readFile(new URL(first, sourceDir));
  const manifest = JSON.stringify(
    {
      projectRef: JSON.parse(target.toString()).projectRef,
      firstMigration: first,
      configSha256: hash(config),
      migrations,
    },
    null,
    2,
  );
  if (mode === "--prepare") {
    await mkdir(new URL("supabase/migrations/", stage), { recursive: true });
    for (const [name, contents] of [
      ["supabase/config.toml", config],
      ["supabase/dev-target.local.json", target],
      [`supabase/migrations/${first}`, source],
      ["manifest.json", manifest + "\n"],
    ]) {
      try {
        await writeFile(new URL(name, stage), contents, { flag: "wx" });
      } catch (error) {
        if (error.code !== "EEXIST") throw error;
        // Never overwrite an existing linked workdir or a changed snapshot.
      }
    }
  }
  await checkDevTarget(
    mode === "--check-linked" ? "linked" : "planned",
    process.env,
    stage,
  );
  if (
    JSON.stringify(
      (await readdir(new URL("supabase/migrations/", stage))).sort(),
    ) !== JSON.stringify([first]) ||
    (await readdir(new URL("supabase/", stage))).some(
      (name) =>
        ![
          "config.toml",
          "dev-target.local.json",
          "migrations",
          ".temp",
          ".branches",
        ].includes(name),
    ) ||
    (await readFile(new URL("manifest.json", stage), "utf8")).trim() !==
      manifest ||
    hash(await readFile(new URL("supabase/config.toml", stage))) !==
      hash(config) ||
    hash(await readFile(new URL("supabase/dev-target.local.json", stage))) !==
      hash(target)
  )
    throw new Error(
      "First-migration snapshot differs from the reviewed bundle.",
    );
  verifyFirstMigrationCopy(
    source,
    await readFile(new URL(`supabase/migrations/${first}`, stage)),
    migrations[first],
  );
  console.log(
    "Offline first-migration snapshot verified: 001 only; no SQL executed.",
  );
  console.log(`Migration SHA-256: ${migrations[first]}`);
}

if (
  process.argv[1] &&
  pathToFileURL(resolve(process.argv[1])).href === import.meta.url
) {
  try {
    if (process.argv.length !== 3)
      throw new Error("Choose one explicit snapshot mode.");
    await run(process.argv[2]);
  } catch (error) {
    console.error(
      error.code
        ? "Could not prepare or inspect the local migration snapshot."
        : error.message,
    );
    process.exitCode = 1;
  }
}
