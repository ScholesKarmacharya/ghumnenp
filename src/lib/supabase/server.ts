import "server-only";

import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

import { getSupabaseEnv } from "@/lib/env/public";

import type { Database } from "./database.types";

type ServerClientOptions = {
  cookieAccess?: "read-only" | "read-write";
};

export async function createServerSupabaseClient({
  cookieAccess = "read-only",
}: ServerClientOptions = {}) {
  const env = getSupabaseEnv();
  const cookieStore = await cookies();

  // Each request gets a new client. Never share user sessions at module scope.
  return createServerClient<Database>(
    env.NEXT_PUBLIC_SUPABASE_URL,
    env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          // Server Components cannot write cookies. Their session refresh must
          // happen in the proxy before rendering. Opt into writes in actions.
          if (cookieAccess === "read-only") return;

          for (const { name, value, options } of cookiesToSet) {
            cookieStore.set(name, value, options);
          }
        },
      },
    },
  );
}
