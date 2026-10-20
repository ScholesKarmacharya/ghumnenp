// Creates copies only. It does not invoke pg_prove, Supabase, or any database.
import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { parse, parsePlPgSQL } from "@libpg-query/parser";
import { checkDevTarget, guardedTestCopy } from "./lib/dev-target.ts";

async function prepare() {
  const mode = process.argv[2] ?? "--linked";
  if (!["--planned", "--linked"].includes(mode) || process.argv.length > 3)
    throw new Error(
      "Choose --planned or --linked for offline test preparation.",
    );
  await checkDevTarget(mode.slice(2));
  const source = new URL("../supabase/tests/", import.meta.url);
  const destination = new URL(
    "../supabase/.temp/ghumne-tests/",
    import.meta.url,
  );
  await mkdir(destination, { recursive: true });
  const files = (await readdir(source))
    .filter((name) => name.endsWith(".sql"))
    .sort();
  for (const name of files) {
    const sql = await readFile(new URL(name, source), "utf8");
    const copy = guardedTestCopy(sql);
    await parse(copy);
    await parsePlPgSQL(copy);
    await writeFile(new URL(name, destination), copy, "utf8");
  }
  console.log(`Prepared ${files.length} guarded test copies; no SQL executed.`);
}

// Keep the pure helper importable by the unit tests without running preparation.
if (
  process.argv[1] &&
  pathToFileURL(resolve(process.argv[1])).href === import.meta.url
) {
  try {
    await prepare();
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
