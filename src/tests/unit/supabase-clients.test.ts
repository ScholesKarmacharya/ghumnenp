import type { CookieMethodsServer, CookieOptions } from "@supabase/ssr";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { createBrowserSupabaseClient } from "../../lib/supabase/client";
import { createServerSupabaseClient } from "../../lib/supabase/server";

type StoredCookie = { name: string; value: string };
type CookieStore = {
  getAll: () => StoredCookie[];
  set: (name: string, value: string, options: CookieOptions) => void;
};

const sdk = vi.hoisted(() => ({
  createBrowserClient: vi.fn<(url: string, key: string) => object>(),
  createServerClient:
    vi.fn<
      (
        url: string,
        key: string,
        options: { cookies: CookieMethodsServer },
      ) => object
    >(),
  cookies: vi.fn<() => Promise<CookieStore>>(),
}));

vi.mock("@supabase/ssr", () => ({
  createBrowserClient: sdk.createBrowserClient,
  createServerClient: sdk.createServerClient,
}));
vi.mock("next/headers", () => ({ cookies: sdk.cookies }));
vi.mock("server-only", () => ({}));

const projectUrl = "https://project.example.com";
const publishableKey = "sb_publishable_inert-client-fixture";

function createCookieStore(cookies: StoredCookie[] = []) {
  return {
    getAll: vi.fn(() => cookies),
    set: vi.fn<CookieStore["set"]>(),
  };
}

function getCookieMethods(callIndex = 0): CookieMethodsServer {
  const options = sdk.createServerClient.mock.calls[callIndex]?.[2];
  if (!options) {
    throw new Error("Expected a server client with cookie methods.");
  }
  return options.cookies;
}

function getSetAll(callIndex = 0) {
  const setAll = getCookieMethods(callIndex).setAll;
  if (!setAll) {
    throw new Error("Expected a setAll cookie callback.");
  }
  return setAll;
}

beforeEach(() => {
  sdk.createBrowserClient.mockReset();
  sdk.createServerClient.mockReset();
  sdk.cookies.mockReset();
  vi.stubEnv("NEXT_PUBLIC_SUPABASE_URL", projectUrl);
  vi.stubEnv("NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY", publishableKey);
  vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", "private-server-fixture");
  sdk.cookies.mockResolvedValue(createCookieStore());
});

afterEach(() => {
  vi.unstubAllEnvs();
});

describe("createBrowserSupabaseClient", () => {
  it("passes only the validated project URL and publishable key to the SDK", () => {
    const client = { fixture: "browser-client" };
    sdk.createBrowserClient.mockReturnValue(client);

    expect(createBrowserSupabaseClient()).toBe(client);
    expect(sdk.createBrowserClient).toHaveBeenCalledTimes(1);
    expect(sdk.createBrowserClient).toHaveBeenCalledWith(
      projectUrl,
      publishableKey,
    );
    expect(sdk.cookies).not.toHaveBeenCalled();
  });

  it("rejects a privileged key before creating an SDK client", () => {
    vi.stubEnv(
      "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
      "sb_secret_private-fixture",
    );

    expect(() => createBrowserSupabaseClient()).toThrow(
      "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
    );
    expect(sdk.createBrowserClient).not.toHaveBeenCalled();
  });
});

describe("createServerSupabaseClient", () => {
  it("passes validated public configuration and cookie access to the SDK", async () => {
    const client = { fixture: "server-client" };
    sdk.createServerClient.mockReturnValue(client);

    expect(await createServerSupabaseClient()).toBe(client);
    expect(sdk.createServerClient).toHaveBeenCalledTimes(1);
    expect(sdk.createServerClient).toHaveBeenCalledWith(
      projectUrl,
      publishableKey,
      {
        cookies: {
          getAll: expect.any(Function),
          setAll: expect.any(Function),
        },
      },
    );
  });

  it("rejects a privileged key before creating an SDK client", async () => {
    vi.stubEnv(
      "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
      "sb_secret_private-fixture",
    );

    await expect(createServerSupabaseClient()).rejects.toThrow(
      "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
    );
    expect(sdk.createServerClient).not.toHaveBeenCalled();
  });

  it("creates separate clients and cookie stores for each request", async () => {
    const firstCookies = [
      { name: "sb-session", value: "first-session-fixture" },
    ];
    const secondCookies = [
      { name: "sb-session", value: "second-session-fixture" },
    ];
    const firstStore = createCookieStore(firstCookies);
    const secondStore = createCookieStore(secondCookies);
    const firstClient = { fixture: "first-client" };
    const secondClient = { fixture: "second-client" };
    sdk.cookies.mockReset();
    sdk.cookies
      .mockResolvedValueOnce(firstStore)
      .mockResolvedValueOnce(secondStore);
    sdk.createServerClient
      .mockReturnValueOnce(firstClient)
      .mockReturnValueOnce(secondClient);

    const clients = await Promise.all([
      createServerSupabaseClient({ cookieAccess: "read-write" }),
      createServerSupabaseClient({ cookieAccess: "read-write" }),
    ]);

    expect(clients[0]).toBe(firstClient);
    expect(clients[1]).toBe(secondClient);
    expect(sdk.cookies).toHaveBeenCalledTimes(2);
    expect(sdk.createServerClient).toHaveBeenCalledTimes(2);
    expect(await getCookieMethods(0).getAll()).toEqual(firstCookies);
    expect(await getCookieMethods(1).getAll()).toEqual(secondCookies);

    await getSetAll(0)(
      [
        {
          name: "sb-session",
          value: "updated-first-session",
          options: { path: "/" },
        },
      ],
      {},
    );
    expect(firstStore.set).toHaveBeenCalledWith(
      "sb-session",
      "updated-first-session",
      {
        path: "/",
      },
    );
    expect(secondStore.set).not.toHaveBeenCalled();
  });

  it.each([undefined, "read-only"] as const)(
    "does not write cookies in read-only server contexts (%s)",
    async (cookieAccess) => {
      const store = createCookieStore([
        { name: "sb-session", value: "read-fixture" },
      ]);
      sdk.cookies.mockResolvedValue(store);

      await createServerSupabaseClient(
        cookieAccess ? { cookieAccess } : undefined,
      );
      expect(await getCookieMethods().getAll()).toEqual([
        { name: "sb-session", value: "read-fixture" },
      ]);
      await getSetAll()(
        [
          {
            name: "sb-session",
            value: "refresh-fixture",
            options: { path: "/" },
          },
        ],
        {},
      );

      expect(store.set).not.toHaveBeenCalled();
    },
  );

  it("preserves cookie options and deletions when writes are explicitly enabled", async () => {
    const store = createCookieStore();
    const cookiesToSet = [
      {
        name: "sb-session.0",
        value: "new-session-fixture",
        options: {
          path: "/",
          httpOnly: true,
          secure: true,
          sameSite: "lax" as const,
          maxAge: 3600,
        },
      },
      {
        name: "sb-session.1",
        value: "",
        options: { path: "/", maxAge: 0, expires: new Date(0) },
      },
    ];
    sdk.cookies.mockResolvedValue(store);

    await createServerSupabaseClient({ cookieAccess: "read-write" });
    await getSetAll()(cookiesToSet, {});

    expect(store.set).toHaveBeenCalledTimes(2);
    for (const [index, cookie] of cookiesToSet.entries()) {
      expect(store.set).toHaveBeenNthCalledWith(
        index + 1,
        cookie.name,
        cookie.value,
        cookie.options,
      );
    }
  });

  it("propagates unexpected cookie write failures", async () => {
    const store = createCookieStore();
    const failure = new Error("Cookie storage unavailable");
    store.set.mockImplementation(() => {
      throw failure;
    });
    sdk.cookies.mockResolvedValue(store);
    await createServerSupabaseClient({ cookieAccess: "read-write" });

    await expect(
      (async () => {
        await getSetAll()(
          [
            {
              name: "sb-session",
              value: "refresh-fixture",
              options: { path: "/" },
            },
          ],
          {},
        );
      })(),
    ).rejects.toBe(failure);
  });
});
