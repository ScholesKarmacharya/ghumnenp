import { spawnSync } from "node:child_process";

const production = process.argv.includes("--production");
const homepage = process.argv.includes("--homepage");
const result = spawnSync(
  process.execPath,
  [
    "node_modules/@playwright/test/cli.js",
    "test",
    ...process.argv
      .slice(2)
      .filter((argument) => !["--production", "--homepage"].includes(argument)),
  ],
  {
    stdio: "inherit",
    env: {
      ...process.env,
      GHUMNE_TEST_MODE: homepage
        ? "homepage"
        : production
          ? "production"
          : "development",
    },
  },
);
if (result.error) throw result.error;
process.exitCode = result.status ?? 1;
