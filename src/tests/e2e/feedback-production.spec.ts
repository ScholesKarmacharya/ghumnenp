import { expect, test } from "@playwright/test";

test("production hides developer preview and serves the existing homepage", async ({
  page,
}) => {
  expect((await page.goto("/ui-preview"))?.status()).toBe(404);
  await expect(
    page.getByRole("heading", { name: "Loading and feedback" }),
  ).toHaveCount(0);
  expect((await page.goto("/"))?.status()).toBe(200);
  await expect(page.getByRole("main")).toHaveCount(1);
  await expect(page.getByRole("heading", { level: 1 })).toHaveText(
    "Your next story starts in Nepal.",
  );
});
