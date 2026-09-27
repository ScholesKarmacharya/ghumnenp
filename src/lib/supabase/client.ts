"use client";

import { createBrowserClient } from "@supabase/ssr";

import { getSupabaseEnv } from "@/lib/env/public";

import type { Database } from "./database.types";

export function createBrowserSupabaseClient() {
  const env = getSupabaseEnv();

  // The SDK manages the browser singleton and its cookie-based session storage.
  return createBrowserClient<Database>(
    env.NEXT_PUBLIC_SUPABASE_URL,
    env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
  );
}
