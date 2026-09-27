import { afterEach, describe, expect, it, vi } from "vitest";

import { parseSupabaseEnv } from "../../lib/env/schema";

const validEnv = {
  NEXT_PUBLIC_SUPABASE_URL: "https://project.example.com",
  NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: "sb_publishable_inert-test_key",
};

afterEach(() => {
  vi.unstubAllEnvs();
  vi.resetModules();
});

describe("parseSupabaseEnv", () => {
  it("trims configuration, normalizes the origin, and strips unrelated values", () => {
    expect(
      parseSupabaseEnv({
        NEXT_PUBLIC_SUPABASE_URL: "  https://project.example.com/  ",
        NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY:
          "  sb_publishable_inert-test_key  ",
        SUPABASE_SERVICE_ROLE_KEY: "private-fixture-must-not-escape",
      }),
    ).toEqual(validEnv);
  });

  it.each([
    ["https://project.example.com:8443/", "https://project.example.com:8443"],
    ["http://localhost:54321/", "http://localhost:54321"],
    ["http://127.0.0.1:54321/", "http://127.0.0.1:54321"],
    ["http://[::1]:54321/", "http://[::1]:54321"],
  ])("accepts the permitted project URL %s", (input, expected) => {
    expect(
      parseSupabaseEnv({ ...validEnv, NEXT_PUBLIC_SUPABASE_URL: input })
        .NEXT_PUBLIC_SUPABASE_URL,
    ).toBe(expected);
  });

  it.each([
    "http://project.example.com",
    "http://localhost.example.com",
    "http://127.0.0.2",
    "ftp://project.example.com",
    "javascript:alert(1)",
    "https://user:password@project.example.com",
    "https://user@project.example.com",
    "https://project.example.com/rest/v1",
    "https://project.example.com/?token=private-fixture",
    "https://project.example.com/#private-fixture",
    "not-a-project-url",
    "",
    "   ",
  ])("rejects unsafe or malformed project URL %s", (url) => {
    expect(() =>
      parseSupabaseEnv({ ...validEnv, NEXT_PUBLIC_SUPABASE_URL: url }),
    ).toThrow("NEXT_PUBLIC_SUPABASE_URL");
  });

  it.each([
    "sb_secret_private-fixture",
    "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiYW5vbiJ9.inert-signature",
    "sb_publishable_",
    "sb_publishable_contains spaces",
    "sb_publishable_key.with.dots",
    "unrecognized-key",
    "",
    "   ",
  ])("rejects a non-publishable key %s", (key) => {
    expect(() =>
      parseSupabaseEnv({
        ...validEnv,
        NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: key,
      }),
    ).toThrow("NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY");
  });

  it.each([undefined, null, [], "configuration", {}, 123])(
    "rejects missing or non-object configuration: %j",
    (input) => {
      expect(() => parseSupabaseEnv(input)).toThrow(Error);
    },
  );

  it.each([undefined, null, 123, false, []])(
    "does not coerce non-string field values: %j",
    (value) => {
      expect(() =>
        parseSupabaseEnv({ ...validEnv, NEXT_PUBLIC_SUPABASE_URL: value }),
      ).toThrow("NEXT_PUBLIC_SUPABASE_URL");
      expect(() =>
        parseSupabaseEnv({
          ...validEnv,
          NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: value,
        }),
      ).toThrow("NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY");
    },
  );

  it("reports invalid field names and setup instructions without revealing values", () => {
    const invalidUrl = "https://private-user:private-password@example.com";
    const invalidKey = "sb_secret_sensitive-fixture";
    let failure: unknown;

    try {
      parseSupabaseEnv({
        NEXT_PUBLIC_SUPABASE_URL: invalidUrl,
        NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: invalidKey,
        SUPABASE_SERVICE_ROLE_KEY: "unrelated-private-fixture",
      });
    } catch (error) {
      failure = error;
    }

    expect(failure).toBeInstanceOf(Error);
    if (!(failure instanceof Error)) {
      throw new Error("Expected environment validation to fail.");
    }

    expect(failure.message).toContain("NEXT_PUBLIC_SUPABASE_URL");
    expect(failure.message).toContain("NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY");
    expect(failure.message).toContain(".env.local");
    expect(failure.message).toContain(".env.example");
    for (const sensitiveValue of [
      invalidUrl,
      "private-user",
      "private-password",
      invalidKey,
      "unrelated-private-fixture",
    ]) {
      expect(String(failure)).not.toContain(sensitiveValue);
      expect(JSON.stringify(failure)).not.toContain(sensitiveValue);
    }
  });
});

describe("getSupabaseEnv", () => {
  it("allows importing without credentials but fails when configuration is requested", async () => {
    vi.stubEnv("NEXT_PUBLIC_SUPABASE_URL", undefined);
    vi.stubEnv("NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY", undefined);

    const { getSupabaseEnv } = await import("../../lib/env/public");

    expect(() => getSupabaseEnv()).toThrow("NEXT_PUBLIC_SUPABASE_URL");
    expect(() => getSupabaseEnv()).toThrow(
      "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
    );
  });

  it("reads current public configuration without returning server secrets", async () => {
    vi.stubEnv("NEXT_PUBLIC_SUPABASE_URL", validEnv.NEXT_PUBLIC_SUPABASE_URL);
    vi.stubEnv(
      "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
      validEnv.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
    );
    vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", "server-only-private-fixture");
    const { getSupabaseEnv } = await import("../../lib/env/public");

    expect(getSupabaseEnv()).toEqual(validEnv);

    vi.stubEnv("NEXT_PUBLIC_SUPABASE_URL", "http://localhost:54321");
    vi.stubEnv(
      "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
      "sb_publishable_changed-fixture",
    );

    expect(getSupabaseEnv()).toEqual({
      NEXT_PUBLIC_SUPABASE_URL: "http://localhost:54321",
      NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: "sb_publishable_changed-fixture",
    });
  });
});
