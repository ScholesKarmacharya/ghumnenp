// Offline checks only. Never imports a database client or invokes the CLI.
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";

export const projectRoot = fileURLToPath(new URL("../../", import.meta.url));

export function validateDevTarget(
  target: unknown,
  linkedRef: string | null,
  appUrl: string | undefined,
) {
  const data = target as Record<string, unknown> | null;
  if (
    !data ||
    data.environment !== "development" ||
    data.projectName !== "ghumne-development" ||
    typeof data.projectRef !== "string" ||
    !/^[a-z0-9]{20}$/.test(data.projectRef)
  ) {
    throw new Error("Configure the reviewed Ghumne development target first.");
  }
  if (linkedRef?.trim() !== data.projectRef) {
    throw new Error("CLI link does not match the reviewed development target.");
  }
  // Require the canonical hosted URL; no custom domains, ports or credentials.
  if (appUrl !== `https://${data.projectRef}.supabase.co`) {
    throw new Error("App URL does not match the reviewed development target.");
  }
}

async function optionalText(relative: string, root: URL) {
  try {
    return await readFile(new URL(relative, root), "utf8");
  } catch (error) {
    if (error instanceof Error && "code" in error && error.code === "ENOENT")
      return null;
    throw new Error("Could not inspect local development target files.");
  }
}

export async function checkDevTarget(
  mode: string,
  env: Record<string, string | undefined> = process.env,
  root = new URL("../../", import.meta.url),
) {
  if (!["unlinked", "planned", "linked"].includes(mode)) {
    throw new Error("Choose --unlinked, --planned or --linked explicitly.");
  }
  // Avoid implicit CLI workdir/stack overrides selecting another checkout.
  if (
    [
      "SUPABASE_WORKDIR",
      "SUPABASE_PROJECT_REF",
      "SUPABASE_EXPERIMENTAL_STACK",
      "DATABASE_URL",
      "SUPABASE_DB_URL",
      "PGHOST",
      "PGPORT",
      "PGDATABASE",
      "PGUSER",
      "PGSERVICE",
      "PGSERVICEFILE",
      "PGOPTIONS",
    ].some((name) => env[name])
  ) {
    throw new Error("Remove implicit Supabase target overrides before setup.");
  }
  const linked = await optionalText("supabase/.temp/project-ref", root);
  if (
    (await optionalText("supabase/.branches/_current_branch", root)) !== null
  ) {
    throw new Error(
      "Review and clear unexpected branch targeting before setup.",
    );
  }
  if (mode === "unlinked") {
    if (
      linked !== null ||
      env.NEXT_PUBLIC_SUPABASE_URL ||
      env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY
    ) {
      throw new Error(
        "A CLI link or app target exists; review it before setup.",
      );
    }
    return;
  }
  let target: unknown;
  try {
    target = JSON.parse(
      (await optionalText("supabase/dev-target.local.json", root)) ?? "null",
    );
  } catch {
    throw new Error("Development target file is missing or invalid JSON.");
  }
  if (mode === "planned") {
    if (linked !== null)
      throw new Error("An existing CLI link must be reviewed before linking.");
    const ref =
      target &&
      typeof target === "object" &&
      "projectRef" in target &&
      typeof target.projectRef === "string"
        ? target.projectRef
        : null;
    validateDevTarget(target, ref, env.NEXT_PUBLIC_SUPABASE_URL);
  } else {
    validateDevTarget(target, linked, env.NEXT_PUBLIC_SUPABASE_URL);
  }
}

export function guardedTestCopy(sql: string) {
  const assertions = sql.match(
    /^select (?:is|ok|throws_ok|lives_ok)\(/gm,
  )?.length;
  if (
    !assertions ||
    !/^begin;\r?$/m.test(sql) ||
    !sql.trimEnd().endsWith("rollback;") ||
    !sql.includes("select no_plan();") ||
    !sql.includes("select * from finish();")
  ) {
    throw new Error(
      "Review the pgTAP suite structure before preparing copies.",
    );
  }
  // The reviewed source suites stay untouched. In copies, failed assertions or
  // an incomplete plan become SQL errors, including in SQL Editor/native psql.
  return (
    "-- GENERATED for the reviewed isolated development target; never production.\n" +
    sql
      .replace(
        /^begin;\r?$/m,
        "begin;\nset local ghumne.allow_test_fixtures = 'yes';\nset local statement_timeout = '120s';\nset local lock_timeout = '5s';",
      )
      .replace("select no_plan();", `select plan(${assertions});`)
      .replace("select * from finish();", "select * from finish(true);") +
    `\nselect 'Ghumne pgTAP: ${assertions} assertions completed and rolled back' as result;\n`
  );
}
