// Syntax-only validation. Never opens a database connection or executes SQL.
import { readdir, readFile } from "node:fs/promises";
import { parse, parsePlPgSQL } from "@libpg-query/parser";

const roots = ["supabase/migrations", "supabase/tests", "supabase/preflight"];
for (const root of roots) {
  const files = (await readdir(root))
    .filter((name) => name.endsWith(".sql"))
    .sort();
  for (const name of files) {
    const sql = await readFile(`${root}/${name}`, "utf8");
    const ast = await parse(sql);
    await parsePlPgSQL(sql);
    for (const statement of ast.stmts) {
      const fn = statement.stmt?.CreateFunctionStmt;
      if (!fn) continue;
      const options = fn.options.map((option) => option.DefElem);
      const language = options.find((option) => option.defname === "language")
        ?.arg?.String?.sval;
      const body = options.find((option) => option.defname === "as")?.arg?.List
        ?.items?.[0]?.String?.sval;
      if (language === "sql" && body) await parse(body);
    }
    // pgTAP's dynamic probes are SQL strings; validate their syntax as well.
    async function checkProbes(value) {
      if (!value || typeof value !== "object") return;
      if (value.FuncCall) {
        const name = value.FuncCall.funcname
          .map((part) => part.String.sval)
          .at(-1);
        const probe = value.FuncCall.args?.[0]?.A_Const?.sval?.sval;
        if (["throws_ok", "lives_ok"].includes(name) && probe)
          await parse(probe);
      }
      for (const child of Object.values(value)) {
        if (Array.isArray(child)) {
          for (const entry of child) await checkProbes(entry);
        } else await checkProbes(child);
      }
    }
    await checkProbes(ast);
    console.log(
      `${root}/${name}: SQL and PL/pgSQL syntax parsed (${ast.stmts.length} statements)`,
    );
  }
}
console.log(
  "No SQL was executed; database semantics and RLS require approved integration tests.",
);
