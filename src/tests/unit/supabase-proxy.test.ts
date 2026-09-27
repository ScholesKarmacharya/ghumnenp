import type { CookieMethodsServer } from "@supabase/ssr";
import { NextRequest } from "next/server";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

const sdk = vi.hoisted(() => ({
  createServerClient: vi.fn(),
  getClaims: vi.fn(),
}));

vi.mock("server-only", () => ({}));
vi.mock("@supabase/ssr", () => ({
  createServerClient: sdk.createServerClient,
}));

import { updateSupabaseSession } from "../../lib/supabase/proxy";

const cacheHeaders = {
  "Cache-Control": "private, no-cache, no-store, must-revalidate, max-age=0",
  Expires: "0",
  Pragma: "no-cache",
};

let cookies: CookieMethodsServer;

beforeEach(() => {
  vi.stubEnv("NEXT_PUBLIC_SUPABASE_URL", "https://project.example.com");
  vi.stubEnv(
    "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
    "sb_publishable_inert-test",
  );
  sdk.createServerClient.mockImplementation(
    (_url: string, _key: string, options: { cookies: CookieMethodsServer }) => {
      cookies = options.cookies;
      return { auth: { getClaims: sdk.getClaims } };
    },
  );
  sdk.getClaims.mockResolvedValue({ data: null, error: null });
});

afterEach(() => {
  vi.unstubAllEnvs();
  vi.resetAllMocks();
});

describe("updateSupabaseSession", () => {
  it("reads request cookies and verifies claims before returning", async () => {
    const request = new NextRequest("http://localhost:3000", {
      headers: { cookie: "session=inert-existing-session" },
    });

    const response = await updateSupabaseSession(request);

    expect(cookies.getAll()).toEqual([
      { name: "session", value: "inert-existing-session" },
    ]);
    expect(sdk.getClaims).toHaveBeenCalledOnce();
    expect(response.status).toBe(200);
    expect(response.cookies.getAll()).toEqual([]);
  });

  it("preserves refreshed cookies, deletions, and cache headers across SDK writes", async () => {
    const request = new NextRequest("http://localhost:3000", {
      headers: { cookie: "old-chunk=stale; preference=retained" },
    });

    sdk.getClaims.mockImplementation(async () => {
      if (!cookies.setAll) throw new Error("Missing cookie write adapter");
      await cookies.setAll(
        [
          {
            name: "session",
            value: "inert-refreshed-session",
            options: { path: "/", sameSite: "lax", secure: true },
          },
        ],
        cacheHeaders,
      );
      await cookies.setAll(
        [{ name: "old-chunk", value: "", options: { path: "/", maxAge: 0 } }],
        {},
      );
      return { data: { claims: { sub: "fixture-user" } }, error: null };
    });

    const response = await updateSupabaseSession(request);

    expect(request.cookies.get("session")?.value).toBe(
      "inert-refreshed-session",
    );
    expect(response.cookies.get("session")).toMatchObject({
      value: "inert-refreshed-session",
      path: "/",
      sameSite: "lax",
      secure: true,
    });
    expect(response.cookies.get("old-chunk")).toMatchObject({
      value: "",
      maxAge: 0,
    });
    expect(response.headers.get("x-middleware-request-cookie")).toContain(
      "session=inert-refreshed-session",
    );
    expect(response.headers.get("x-middleware-request-cookie")).toContain(
      "preference=retained",
    );
    expect(response.headers.get("cache-control")).toBe(
      cacheHeaders["Cache-Control"],
    );
    expect(response.headers.get("expires")).toBe("0");
    expect(response.headers.get("pragma")).toBe("no-cache");
  });

  it("keeps cookie state separate between requests", async () => {
    const first = new NextRequest("http://localhost:3000", {
      headers: { cookie: "session=first" },
    });
    await updateSupabaseSession(first);
    const firstCookies = cookies;

    const second = new NextRequest("http://localhost:3000", {
      headers: { cookie: "session=second" },
    });
    await updateSupabaseSession(second);

    expect(sdk.createServerClient).toHaveBeenCalledTimes(2);
    expect(firstCookies.getAll()).toEqual([
      { name: "session", value: "first" },
    ]);
    expect(cookies.getAll()).toEqual([{ name: "session", value: "second" }]);
  });

  it("does not hide unexpected SDK failures", async () => {
    sdk.getClaims.mockRejectedValue(new Error("inert network failure"));

    await expect(
      updateSupabaseSession(new NextRequest("http://localhost:3000")),
    ).rejects.toThrow("inert network failure");
  });

  it("rejects a privileged key before creating the SDK client", async () => {
    vi.stubEnv(
      "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
      "sb_secret_inert-fixture",
    );

    await expect(
      updateSupabaseSession(new NextRequest("http://localhost:3000")),
    ).rejects.toThrow("NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY");
    expect(sdk.createServerClient).not.toHaveBeenCalled();
  });
});
