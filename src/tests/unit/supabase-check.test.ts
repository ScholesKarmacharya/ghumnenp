import { spawnSync } from "node:child_process";

import { describe, expect, it } from "vitest";

const scriptUrl = new URL(
  "../../../scripts/check-supabase.mjs",
  import.meta.url,
);
const publishableKey = "sb_publishable_private-cli-fixture";
const privateResponseValue = "private-response-fixture-must-not-be-logged";

const validSettings = {
  external: { email: true, phone: false },
  disable_signup: false,
  mailer_autoconfirm: false,
};

const cases = [
  {
    name: "accepts a recognizable Supabase Auth settings response",
    status: 200,
    contentType: "application/json",
    body: JSON.stringify({ ...validSettings, privateResponseValue }),
    networkFailure: false,
    expectedExitCode: 0,
    expectedMessage: "Supabase Auth settings are reachable",
  },
  {
    name: "rejects an unauthorized response without logging its body",
    status: 401,
    contentType: "application/json",
    body: JSON.stringify({ message: privateResponseValue }),
    networkFailure: false,
    expectedExitCode: 1,
    expectedMessage: "Supabase configuration check failed (HTTP 401)",
  },
  {
    name: "rejects a successful HTML response from an unrelated host",
    status: 200,
    contentType: "text/html",
    body: `<html>${privateResponseValue}</html>`,
    networkFailure: false,
    expectedExitCode: 1,
    expectedMessage: "Endpoint did not return valid Supabase Auth settings",
  },
  {
    name: "rejects unrelated JSON even when its HTTP status is successful",
    status: 200,
    contentType: "application/json",
    body: JSON.stringify({ message: privateResponseValue }),
    networkFailure: false,
    expectedExitCode: 1,
    expectedMessage: "Endpoint did not return valid Supabase Auth settings",
  },
  {
    name: "rejects settings with invalid field types",
    status: 200,
    contentType: "application/json",
    body: JSON.stringify({
      ...validSettings,
      external: { email: "true", phone: false },
      privateResponseValue,
    }),
    networkFailure: false,
    expectedExitCode: 1,
    expectedMessage: "Endpoint did not return valid Supabase Auth settings",
  },
  {
    name: "handles network failures without exposing error details",
    status: 200,
    contentType: "application/json",
    body: privateResponseValue,
    networkFailure: true,
    expectedExitCode: 1,
    expectedMessage: "Supabase connection failed",
  },
];

describe("supabase configuration check CLI", () => {
  it.each(cases)("$name", (scenario) => {
    const childScript = `
      const scenario = ${JSON.stringify(scenario)};
      let requests = 0;
      globalThis.fetch = async (url, options) => {
        requests += 1;
        if (
          String(url) !== "https://project.example.com/auth/v1/settings" ||
          options?.headers?.apikey !== process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY ||
          options?.redirect !== "error" ||
          !(options?.signal instanceof AbortSignal)
        ) {
          throw new Error("Unexpected verification request.");
        }
        if (scenario.networkFailure) throw new Error(scenario.body);
        return new Response(scenario.body, {
          status: scenario.status,
          headers: { "Content-Type": scenario.contentType },
        });
      };
      await import(${JSON.stringify(scriptUrl.href)});
      if (requests !== 1) process.exitCode = 2;
    `;

    const result = spawnSync(
      process.execPath,
      ["--input-type=module", "--eval", childScript],
      {
        encoding: "utf8",
        timeout: 10_000,
        env: {
          NODE_ENV: "test",
          NEXT_PUBLIC_SUPABASE_URL: "https://project.example.com",
          NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: publishableKey,
          SUPABASE_SERVICE_ROLE_KEY: "private-server-cli-fixture",
        },
      },
    );

    expect(result.error).toBeUndefined();
    expect(result.signal).toBeNull();
    expect(result.status).toBe(scenario.expectedExitCode);
    if (scenario.expectedExitCode === 0) {
      expect(result.stdout).toContain("Supabase Auth settings are reachable");
      expect(result.stderr).toBe("");
    } else {
      expect(result.stderr.trim().length).toBeGreaterThan(0);
      expect(result.stdout).not.toContain(
        "Supabase Auth settings are reachable",
      );
    }

    const output = result.stdout + result.stderr;
    expect(output).toContain(scenario.expectedMessage);
    expect(output).not.toContain(privateResponseValue);
    expect(output).not.toContain(publishableKey);
    expect(output).not.toContain("private-server-cli-fixture");
  });
});
