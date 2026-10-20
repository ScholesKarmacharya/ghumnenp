import { createHash } from "node:crypto";

export function migrationHash(value: string | Uint8Array) {
  return createHash("sha256").update(value).digest("hex");
}

export function verifyFirstMigrationCopy(
  source: Uint8Array,
  copy: Uint8Array,
  approvedHash: string,
) {
  if (
    migrationHash(source) !== approvedHash ||
    migrationHash(copy) !== approvedHash
  )
    throw new Error("First migration changed; regenerate and review the plan.");
}
