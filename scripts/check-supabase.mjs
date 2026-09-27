import { z } from "zod";

import { parseSupabaseEnv } from "../src/lib/env/schema.ts";

const authSettingsSchema = z.object({
  external: z.object({ email: z.boolean(), phone: z.boolean() }),
  disable_signup: z.boolean(),
  mailer_autoconfirm: z.boolean(),
});

async function checkSupabase() {
  let env;
  try {
    env = parseSupabaseEnv(process.env);
  } catch (error) {
    // The parser emits field names only, never supplied values.
    console.error(
      error instanceof Error
        ? error.message
        : "Invalid Supabase configuration.",
    );
    process.exitCode = 1;
    return;
  }

  try {
    const response = await fetch(
      new URL("/auth/v1/settings", env.NEXT_PUBLIC_SUPABASE_URL),
      {
        headers: { apikey: env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY },
        signal: AbortSignal.timeout(10_000),
        redirect: "error",
      },
    );

    if (!response.ok) {
      console.error(
        `Supabase configuration check failed (HTTP ${response.status}).`,
      );
      process.exitCode = 1;
      return;
    }

    const settings = await response.json().catch(() => null);
    if (!authSettingsSchema.safeParse(settings).success) {
      console.error("Endpoint did not return valid Supabase Auth settings.");
      process.exitCode = 1;
      return;
    }

    console.log("Supabase Auth settings are reachable. No data was changed.");
  } catch {
    console.error(
      "Supabase connection failed. Check the project URL and network access.",
    );
    process.exitCode = 1;
  }
}

await checkSupabase();
