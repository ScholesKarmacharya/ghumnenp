import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";

test("feedback is accessible and retry works with the keyboard", async ({
  page,
}) => {
  const errors: string[] = [];
  page.on("pageerror", (error) => errors.push(error.message));
  await page.goto("/ui-preview");
  const feedback = page
    .locator("section", {
      has: page.getByRole("heading", { name: "Loading and feedback" }),
    })
    .first();
  await expect(feedback.getByRole("status").first()).toHaveText(
    "Loading example content…",
  );
  await expect(feedback.getByRole("alert")).toHaveAccessibleName(
    "Example loading error",
  );
  const retry = feedback.getByRole("button", { name: "Retry example" });
  await retry.focus();
  await page.keyboard.press("Enter");
  await expect(
    feedback.getByRole("status", { name: "Retry result" }),
  ).toHaveText("Retry attempts: 1.");
  const focusStyle = await retry.evaluate((button) => {
    const style = getComputedStyle(button);
    return { width: style.outlineWidth, style: style.outlineStyle };
  });
  expect(focusStyle.style).not.toBe("none");
  expect(parseFloat(focusStyle.width)).toBeGreaterThan(0);
  const results = await new AxeBuilder({ page })
    .include("main")
    .withTags(["wcag2a", "wcag2aa", "wcag21aa"])
    .analyze();
  expect(results.violations).toEqual([]);
  expect(errors).toEqual([]);
});

for (const width of [320, 390, 768, 1440]) {
  test(`feedback reflows at ${width}px and doubled text`, async ({
    page,
  }, testInfo) => {
    await page.setViewportSize({ width, height: 900 });
    await page.goto("/ui-preview");
    for (const size of ["100%", "200%"]) {
      await page.evaluate((value) => {
        document.documentElement.style.fontSize = value;
      }, size);
      expect(
        await page.evaluate(
          () => document.documentElement.scrollWidth <= window.innerWidth,
        ),
      ).toBe(true);
      const retry = page.getByRole("button", { name: "Retry example" });
      const box = await retry.boundingBox();
      expect(box?.height).toBeGreaterThanOrEqual(44);
      await expect(
        page.getByRole("heading", { name: "Nothing to show yet" }),
      ).toBeVisible();
    }
    await page.emulateMedia({ reducedMotion: "reduce" });
    const duration = await page
      .locator('[aria-hidden="true"].motion-safe\\:animate-pulse')
      .first()
      .evaluate((element) => getComputedStyle(element).animationDuration);
    expect(parseFloat(duration)).toBeLessThanOrEqual(0.01);
    if (width === 320 || width === 1440) {
      await page.evaluate(() => {
        document.documentElement.style.fontSize = "100%";
      });
      await page.screenshot({ path: testInfo.outputPath("feedback.png") });
    }
  });
}

test("not-found page has a safe accessible recovery action", async ({
  page,
}) => {
  const response = await page.goto("/feedback-route-that-does-not-exist");
  expect(response?.status()).toBe(404);
  await expect(page.getByRole("main")).toHaveCount(1);
  await expect(page.getByRole("heading", { level: 1 })).toHaveText(
    "We couldn't find that page",
  );
  expect((await new AxeBuilder({ page }).analyze()).violations).toEqual([]);
  await page.getByRole("link", { name: "Return home" }).click();
  await expect(page).toHaveURL("/");
});
