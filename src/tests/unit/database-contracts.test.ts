import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { parse, parsePlPgSQL } from "@libpg-query/parser";
import { beforeAll, describe, expect, it } from "vitest";

type JsonRecord = Record<string, unknown>;
function object(value: unknown): JsonRecord {
  if (value === null || typeof value !== "object" || Array.isArray(value))
    return {};
  return value as JsonRecord;
}
function array(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}
function strings(nodes: unknown): string {
  return array(nodes)
    .map((node) => object(object(node).String).sval)
    .join(".");
}
function relation(value: unknown): string {
  const row = object(value);
  return `${row.schemaname}.${row.relname}`;
}
const directory = join(process.cwd(), "supabase", "migrations");
const files = readdirSync(directory)
  .filter((file) => file.endsWith(".sql"))
  .sort();
const sources = files.map((file) =>
  readFileSync(join(directory, file), "utf8"),
);
const all = sources.join("\n");
const statements: JsonRecord[] = [];
beforeAll(async () => {
  for (const source of sources) {
    const ast = await parse(source);
    statements.push(
      ...array(object(ast).stmts).map((entry) => object(object(entry).stmt)),
    );
  }
});

describe("review-only migration contracts", () => {
  it.each(files)("parses PostgreSQL and procedure syntax: %s", async (file) => {
    const source = readFileSync(join(directory, file), "utf8");
    expect((await parse(source)).stmts?.length ?? 0).toBeGreaterThan(0);
    await expect(parsePlPgSQL(source)).resolves.toBeDefined();
    expect(source).toMatch(/REVIEW DRAFT/);
    expect(source).toMatch(/begin;/i);
    expect(source.trim()).toMatch(/commit;$/i);
  });

  it("rejects malformed SQL and PL/pgSQL instead of treating text checks as parsing", async () => {
    await expect(
      parse("create table broken(id uuid primary nonsense);"),
    ).rejects.toThrow();
    await expect(
      parsePlPgSQL(
        "create function broken() returns void language plpgsql as $$ begin if then return; end $$;",
      ),
    ).rejects.toThrow();
  });

  it("enables RLS and explicitly revokes API defaults on every created table", () => {
    const tables = statements
      .filter((node) => node.CreateStmt)
      .map((node) => relation(object(node.CreateStmt).relation));
    expect(tables.length).toBeGreaterThanOrEqual(40);
    const enabled = new Set(
      statements
        .filter((node) => {
          const alter = object(node.AlterTableStmt);
          return array(alter.cmds).some(
            (cmd) =>
              object(object(cmd).AlterTableCmd).subtype ===
              "AT_EnableRowSecurity",
          );
        })
        .map((node) => relation(object(node.AlterTableStmt).relation)),
    );
    const revoked = new Map<string, Set<string>>();
    for (const node of statements) {
      const grant = object(node.GrantStmt);
      if (grant.is_grant || grant.objtype !== "OBJECT_TABLE") continue;
      const roles = array(grant.grantees).map((role) => {
        const spec = object(object(role).RoleSpec);
        return spec.roletype === "ROLESPEC_PUBLIC"
          ? "public"
          : String(spec.rolename);
      });
      for (const target of array(grant.objects)) {
        const table = relation(object(target).RangeVar);
        revoked.set(table, new Set([...(revoked.get(table) ?? []), ...roles]));
      }
    }
    for (const table of tables) {
      expect(enabled.has(table), table).toBe(true);
      expect([...(revoked.get(table) ?? [])].sort(), table).toEqual([
        "anon",
        "authenticated",
        "public",
        "service_role",
      ]);
    }
  });

  it("does not expose raw tenant tables or any public write RPC to anonymous callers", () => {
    const permitted = new Set([
      "public.quote_package",
      "public.catalog_destinations",
      "public.catalog_packages",
      "public.package_detail",
      "public.sponsored_packages",
      "public.shared_trip",
    ]);
    for (const node of statements) {
      const grant = object(node.GrantStmt);
      if (!grant.is_grant) continue;
      const roles = array(grant.grantees).map((role) =>
        object(object(role).RoleSpec),
      );
      expect(roles.some((role) => role.roletype === "ROLESPEC_PUBLIC")).toBe(
        false,
      );
      if (!roles.some((role) => role.rolename === "anon")) continue;
      expect(grant.objtype).toBe("OBJECT_FUNCTION");
      for (const target of array(grant.objects)) {
        expect(
          permitted.has(strings(object(object(target).ObjectWithArgs).objname)),
        ).toBe(true);
      }
    }
  });

  it("fixes every function search path and revokes implicit PUBLIC execution", () => {
    const functions = statements.filter((node) => node.CreateFunctionStmt);
    expect(functions.length).toBeGreaterThan(30);
    for (const node of functions) {
      const fn = object(node.CreateFunctionStmt);
      const name = strings(fn.funcname);
      const options = array(fn.options).map((option) =>
        object(object(option).DefElem),
      );
      const path = options.find((option) => option.defname === "set");
      expect(object(object(path?.arg).VariableSetStmt).name, name).toBe(
        "search_path",
      );
      expect(JSON.stringify(path?.arg), name).toContain('"sval":""');
      const escaped = name.replaceAll(".", "\\.");
      expect(all, name).toMatch(
        new RegExp(`revoke all on function ${escaped}\\(`, "i"),
      );
    }
  });

  it("protects identity and published state from ordinary table writes", () => {
    const protectedTables = new Set(
      [
        "user_roles",
        "agency_memberships",
        "agencies",
        "agency_subscriptions",
        "packages",
        "inquiries",
        "featured_placements",
        "audit_logs",
      ].map((table) => `public.${table}`),
    );
    for (const node of statements) {
      const grant = object(node.GrantStmt);
      if (!grant.is_grant || grant.objtype !== "OBJECT_TABLE") continue;
      const authenticated = array(grant.grantees).some(
        (role) => object(object(role).RoleSpec).rolename === "authenticated",
      );
      if (!authenticated) continue;
      for (const target of array(grant.objects)) {
        const table = relation(object(target).RangeVar);
        if (!protectedTables.has(table)) continue;
        const privileges = array(grant.privileges).map(
          (privilege) => object(object(privilege).AccessPriv).priv_name,
        );
        expect(privileges.length, table).toBeGreaterThan(0);
        expect(privileges, table).toEqual(["select"]);
      }
    }
    expect(all).toContain("grant update(display_name,avatar_url)");
    expect(all).toContain("Only draft content can change");
    expect(all).toContain("Approved revision or identity is immutable");
  });

  it("keeps public eligibility time-bounded and independent of paid ranking", () => {
    const source =
      sources.find((sql) =>
        sql.includes("create function private.package_visible"),
      ) ?? "";
    for (const condition of [
      "a.approval_status='approved'",
      "a.operational_status='active'",
      "r.status='approved'",
      "private.effective_plan",
      "package_reconfirmation_days",
      "max_published_packages",
      "statement_timestamp()<s.ends_at",
    ]) {
      expect(source).toContain(condition);
    }
    expect(all).toContain("label='Sponsored'");
    expect(all).not.toMatch(
      /organic_(?:boost|priority)|commission_rate|payment_intent/i,
    );
  });

  it("enforces tenant references, nonoverlapping scopes and safe integer money", () => {
    expect(all).toContain("foreign key(revision_id,package_id,agency_id)");
    expect(all).toContain("foreign key(price_rule_id,revision_id,agency_id)");
    expect(all).toContain(
      "exclude using gist (agency_id with =,active_period with &&)",
    );
    expect(all).toContain(
      "group_scope with &&,travel_scope with &&,sales_scope with &&",
    );
    expect(all).toContain("v_total>9000000000000000");
    expect(all).not.toMatch(
      /(?:price|amount|cost|budget)\w*\s+(?:real|float|double precision|money)\b/i,
    );
    expect(all).not.toMatch(
      /on delete cascade|disable row level security|drop table/i,
    );
  });

  it("contains only operational configuration seed records", () => {
    const topLevelInserts = statements
      .filter((node) => node.InsertStmt)
      .map((node) => relation(object(node.InsertStmt).relation));
    expect(topLevelInserts).toEqual([
      "public.marketplace_settings",
      "public.retention_policies",
    ]);
  });

  it("keeps inquiries backend-only and derives tenant/quote inside the database", () => {
    const source =
      sources.find((sql) =>
        sql.includes("create function public.submit_inquiry"),
      ) ?? "";
    expect(source).toMatch(
      /grant execute on function public\.submit_inquiry\([^;]+\) to service_role;/,
    );
    expect(source).not.toMatch(
      /grant execute on function public\.submit_inquiry\([^;]+\) to (?:anon|authenticated)/,
    );
    expect(source).toContain("v_quote:=private.quote_package");
    expect(source).toContain(
      "select agency_id into strict v_agency from public.packages",
    );
    expect(source).toContain("public.inquiry_rate_limits");
    expect(source).toContain("Idempotency key conflict");
  });
});
