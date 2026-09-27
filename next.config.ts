import type { NextConfig } from "next";

import { getSupabaseEnv } from "./src/lib/env/public.ts";

// Reject invalid public configuration before Next.js can bundle its values.
// An entirely unconfigured foundation can still build its static routes.
if (
  process.env.NEXT_PUBLIC_SUPABASE_URL !== undefined ||
  process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY !== undefined
) {
  getSupabaseEnv();
}

const nextConfig: NextConfig = {
  poweredByHeader: false,
  reactStrictMode: true,
};

export default nextConfig;
