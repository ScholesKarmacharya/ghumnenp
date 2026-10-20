import { createHash } from "node:crypto";
import { readFileSync, readdirSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";
import {
  checkDevTarget,
  guardedTestCopy,
  validateDevTarget,
} from "../../../scripts/lib/dev-target.ts";
import { verifyFirstMigrationCopy } from "../../../scripts/lib/first-migration.ts";

const fixtureRef = "abcdefghijklmnopqrst";
const target = {
  environment: "development",
  projectName: "ghumne-development",
  projectRef: fixtureRef,
};
const fixtureUrl = `https://${fixtureRef}.supabase.co`;
const read = (path: string) => readFileSync(resolve(path), "utf8");

describe("offline Supabase development target guard", () => {
  it("accepts matching reviewed development identifiers", () => {
    expect(() =>
      validateDevTarget(target, `${fixtureRef}\n`, fixtureUrl),
    ).not.toThrow();
  });

  it.each([
    null,
    {},
    { ...target, environment: "production" },
    { ...target, projectName: "another-project" },
    { ...target, projectRef: "" },
    { ...target, projectRef: "not-a-project-ref" },
  ])("rejects an unreviewed or invalid target %#", (input) => {
    expect(() => validateDevTarget(input, fixtureRef, fixtureUrl)).toThrow(
      "Configure the reviewed Ghumne development target",
    );
  });

  it.each([null, "", "zyxwvutsrqponmlkjihg"])(
    "rejects a missing or different CLI link %#",
    (linked) => {
      expect(() => validateDevTarget(target, linked, fixtureUrl)).toThrow(
        "CLI link does not match",
      );
    },
  );

  it.each([
    undefined,
    "https://zyxwvutsrqponmlkjihg.supabase.co",
    `https://${fixtureRef}.supabase.co.evil.invalid`,
    `https://${fixtureRef}.supabase.co:8443`,
    `https://secret@example.invalid`,
    "http://localhost:54821",
  ])("rejects unmatched or noncanonical hosted URLs %#", (url) => {
    expect(() => validateDevTarget(target, fixtureRef, url)).toThrow(
      "App URL does not match",
    );
  });

  it("never includes supplied URL credentials or target values in errors", () => {
    const secret = "private-fixture-that-must-not-escape";
    try {
      validateDevTarget(
        target,
        fixtureRef,
        `https://${secret}@example.invalid`,
      );
      throw new Error("Guard unexpectedly accepted unsafe URL");
    } catch (error) {
      expect((error as Error).message).not.toContain(secret);
      expect((error as Error).message).not.toContain(fixtureRef);
    }
  });

  it.each([
    "SUPABASE_WORKDIR",
    "SUPABASE_PROJECT_REF",
    "DATABASE_URL",
    "PGHOST",
    "PGOPTIONS",
  ])(
    "rejects implicit target override %s before reading target files",
    async (name) => {
      await expect(
        checkDevTarget("linked", { [name]: "inert-fixture" }),
      ).rejects.toThrow("Remove implicit Supabase target overrides");
    },
  );

  it("requires an explicit targeting mode", async () => {
    await expect(checkDevTarget("", {})).rejects.toThrow(
      "Choose --unlinked, --planned or --linked",
    );
  });
});

describe("database preparation preservation", () => {
  it("retains the nine migration files and original 81-assertion suite", () => {
    expect(
      readdirSync("supabase/migrations").filter((file) =>
        file.endsWith(".sql"),
      ),
    ).toHaveLength(9);
    const original = read(
      "supabase/tests/0001_marketplace.test.sql",
    ).replaceAll("\r\n", "\n");
    expect(createHash("sha256").update(original).digest("hex")).toBe(
      "90d178d90e90a2404239864f6f555adaa08027eaecee7304eb4c975ba516c09a",
    );
    expect(
      original.match(/^select (?:is|ok|throws_ok|lives_ok)\(/gm),
    ).toHaveLength(81);
  });

  it("prepares copies without altering the guarded rolled-back source suites", () => {
    for (const file of readdirSync("supabase/tests").filter((file) =>
      file.endsWith(".sql"),
    )) {
      const sql = read(`supabase/tests/${file}`);
      const copy = guardedTestCopy(sql);
      expect(
        copy.indexOf("set local ghumne.allow_test_fixtures = 'yes';"),
      ).toBeGreaterThan(copy.indexOf("begin;"));
      expect(copy).not.toContain("select no_plan();");
      const assertions = sql.match(
        /^select (?:is|ok|throws_ok|lives_ok)\(/gm,
      )?.length;
      expect(copy).toContain(`select plan(${assertions});`);
      expect(copy).toContain("select * from finish(true);");
      expect(copy).toContain("assertions completed and rolled back");
      expect(sql).toContain(
        "current_setting('ghumne.allow_test_fixtures',true)",
      );
      expect(sql.trim()).toMatch(/rollback;$/);
      expect(sql).toContain("select * from finish();");
    }
  });

  it("rejects a test copy without a complete rollback/finish boundary", () => {
    expect(() => guardedTestCopy("begin; select ok(true);")).toThrow(
      "Review the pgTAP suite structure",
    );
  });

  it("rejects a changed source or staged first migration against its approval hash", () => {
    const source = Buffer.from("synthetic migration snapshot");
    const digest = createHash("sha256").update(source).digest("hex");
    expect(() =>
      verifyFirstMigrationCopy(source, source, digest),
    ).not.toThrow();
    expect(() =>
      verifyFirstMigrationCopy(source, Buffer.from("changed"), digest),
    ).toThrow("First migration changed");
    expect(() =>
      verifyFirstMigrationCopy(Buffer.from("changed"), source, digest),
    ).toThrow("First migration changed");
  });
});
