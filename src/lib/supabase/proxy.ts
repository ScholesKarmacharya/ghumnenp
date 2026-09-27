import "server-only";

import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

import { getSupabaseEnv } from "@/lib/env/public";

import type { Database } from "./database.types";

export async function updateSupabaseSession(request: NextRequest) {
  const env = getSupabaseEnv();
  let response = NextResponse.next({ request });

  const supabase = createServerClient<Database>(
    env.NEXT_PUBLIC_SUPABASE_URL,
    env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet, cacheHeaders) {
          for (const { name, value } of cookiesToSet) {
            request.cookies.set(name, value);
          }

          // Refresh forwarded request cookies for the downstream render. Keep
          // earlier response cookies/headers if the SDK writes more than once.
          const previous = response;
          response = NextResponse.next({ request });
          for (const cookie of previous.cookies.getAll()) {
            response.cookies.set(cookie);
          }
          for (const name of ["cache-control", "expires", "pragma"]) {
            const value = previous.headers.get(name);
            if (value) response.headers.set(name, value);
          }

          for (const { name, value, options } of cookiesToSet) {
            response.cookies.set(name, value, options);
          }
          for (const [name, value] of Object.entries(cacheHeaders)) {
            response.headers.set(name, value);
          }
        },
      },
    },
  );

  // Verify claims and allow the SDK to refresh tokens before returning headers.
  // This helper does not authorize a role or replace route-level checks/RLS.
  await supabase.auth.getClaims();

  return response;
}
