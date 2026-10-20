import { defineConfig } from "@playwright/test";

const homepage = process.env.GHUMNE_TEST_MODE === "homepage";
const production = process.env.GHUMNE_TEST_MODE === "production" || homepage;
const port = production ? 3126 : 3000;

export default defineConfig({
  testDir: "./src/tests/e2e",
  testMatch: homepage
    ? "homepage.spec.ts"
    : production
      ? "feedback-production.spec.ts"
      : "feedback.spec.ts",
  outputDir: "test-results/playwright",
  fullyParallel: false,
  workers: 1,
  reporter: "list",
  use: {
    baseURL: `http://localhost:${port}`,
    browserName: "chromium",
    channel: process.platform === "win32" ? "msedge" : undefined,
    headless: true,
    trace: "retain-on-failure",
  },
  webServer: {
    command: `node node_modules/next/dist/bin/next ${production ? "start" : "dev"} --hostname localhost --port ${port}`,
    url: `http://localhost:${port}`,
    reuseExistingServer: !production,
    timeout: 120_000,
    env: { NEXT_TELEMETRY_DISABLED: "1" },
  },
});
