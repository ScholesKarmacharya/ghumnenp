import { parseSupabaseEnv } from "./schema.ts";

export function getSupabaseEnv() {
  // Keep direct reads so Next.js can inline these two public build-time values.
  // Validate at use time so unrelated static pages build without service setup.
  return parseSupabaseEnv({
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY:
      process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
  });
}
