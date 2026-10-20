import { checkDevTarget } from "./lib/dev-target.ts";

try {
  if (process.argv.length !== 3) {
    throw new Error("Choose --unlinked, --planned or --linked explicitly.");
  }
  await checkDevTarget(process.argv[2].replace(/^--/, ""));
  console.log("Offline development target check passed. No connection opened.");
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
