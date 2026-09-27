import { z } from "zod";

const supabaseUrlSchema = z
  .string()
  .trim()
  .refine((value) => {
    try {
      const url = new URL(value);
      const isLocal = ["localhost", "127.0.0.1", "[::1]"].includes(
        url.hostname,
      );

      return (
        (url.protocol === "https:" || (url.protocol === "http:" && isLocal)) &&
        !url.username &&
        !url.password &&
        url.pathname === "/" &&
        !url.search &&
        !url.hash
      );
    } catch {
      return false;
    }
  })
  .transform((value) => new URL(value).origin);

const supabaseEnvSchema = z.object({
  NEXT_PUBLIC_SUPABASE_URL: supabaseUrlSchema,
  NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: z
    .string()
    .trim()
    .regex(/^sb_publishable_[A-Za-z0-9_-]+$/),
});

export type SupabaseEnv = z.infer<typeof supabaseEnvSchema>;

export function parseSupabaseEnv(input: unknown): SupabaseEnv {
  const result = supabaseEnvSchema.safeParse(input);

  if (!result.success) {
    // Include field names only: configuration values may contain pasted secrets.
    const fields = [
      ...new Set(result.error.issues.map((issue) => issue.path.join("."))),
    ]
      .filter(Boolean)
      .join(", ");

    throw new Error(
      `Invalid Supabase configuration${fields ? `: ${fields}` : ""}. Set these values in .env.local using .env.example.`,
    );
  }

  return result.data;
}
