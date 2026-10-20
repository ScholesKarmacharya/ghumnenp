import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";
import { mkdir, readFile } from "node:fs/promises";
import { captureReference } from "./support/stitch-reference";

test("homepage preserves the approved section order and honest inventory boundaries", async ({
  page,
}) => {
  const remote: string[] = [];
  const errors: string[] = [];
  page.on("request", (request) => {
    if (!["localhost", "127.0.0.1"].includes(new URL(request.url()).hostname))
      remote.push(request.url());
  });
  page.on("pageerror", (error) => errors.push(error.message));
  expect((await page.goto("/"))?.status()).toBe(200);
  await expect(page.getByRole("main")).toHaveCount(1);
  await expect(page.getByRole("heading", { level: 1 })).toHaveText(
    "Your next story starts in Nepal.",
  );
  await expect(page.locator("main > section")).toHaveCount(7);
  await expect(page.locator("[data-journey-preview]")).toHaveCount(6);
  await expect(
    page.getByText("No live agency packages are published here.", {
      exact: false,
    }),
  ).toBeVisible();
  await expect(page.locator("main")).not.toContainText(
    /100% Licensed|42 Matched|NPR 145,000|Highland Sherpa|Dawa Norbu|0%|protection escrow/,
  );
  await expect(page).toHaveTitle("Discover Nepal. Plan your journey. | Ghumne");
  await expect(page.locator('meta[name="description"]')).toHaveAttribute(
    "content",
    /personal trip brief/,
  );
  expect(remote).toEqual([]);
  expect(errors).toEqual([]);
  await expect(
    page.getByRole("img", {
      name: "The Himalayan skyline above mist-filled valleys at dawn",
    }),
  ).toHaveAttribute("fetchpriority", "high");
});

test("destination search filters real previews and passes preferences into the brief", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByLabel("Destination", { exact: true }).fill("Pokhara");
  await page
    .getByLabel("Starting hub", { exact: true })
    .selectOption("Pokhara");
  await page
    .getByLabel("Season preference", { exact: true })
    .selectOption("Winter");
  await page.getByLabel("Travelers", { exact: true }).fill("4");
  await page.getByRole("button", { name: "Search", exact: true }).click();
  await expect(page).toHaveURL(/q=Pokhara/);
  await expect(page.locator("#destinations article")).toHaveCount(1);
  await expect(
    page.getByLabel("Destination idea", { exact: false }),
  ).toHaveValue("Pokhara");
  await expect(page.getByLabel("Preferred season")).toHaveValue("Winter");
  await expect(page.getByLabel("Number of travelers")).toHaveValue("4");
  await expect(
    page.getByRole("radio", { name: "Pokhara", exact: true }),
  ).toBeChecked();
  await page.goto("/?q=unavailable-place#destinations");
  await expect(
    page.getByRole("heading", { name: "A new direction awaits" }),
  ).toBeVisible();
  await page.getByRole("link", { name: "Explore all previews" }).click();
  await expect(page.locator("#destinations article")).toHaveCount(5);
});

test("itinerary filters, empty-state recovery, and preview links work", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Annapurna", exact: true }).click();
  await expect(page.locator("[data-journey-preview]")).toHaveCount(1);
  await page.getByRole("button", { name: "Under 7 Days" }).click();
  await expect(
    page.getByRole("heading", { name: "No preview matches these filters" }),
  ).toBeVisible();
  await page.getByRole("button", { name: "Clear filters" }).click();
  await expect(page.locator("[data-journey-preview]")).toHaveCount(6);
  await page.locator("#destinations article").first().getByRole("link").click();
  await expect(
    page.getByLabel("Destination idea", { exact: false }),
  ).toHaveValue("Mustang");
});

test("trip finder creates and downloads an honest brief and clears stale output", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByLabel("Destination idea", { exact: false }).fill("Rara Lake");
  await page.getByLabel("Number of travelers").fill("4");
  await page.getByRole("button", { name: "Create my trip brief" }).click();
  await expect(
    page.getByRole("heading", { name: "Your journey, taking shape." }),
  ).toBeVisible();
  const downloadPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Download your trip brief" }).click();
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toBe("ghumne-trip-brief.txt");
  const path = await download.path();
  const brief = await readFile(path!, "utf8");
  expect(brief).toContain("Destination idea: Rara Lake");
  expect(brief).toContain("Travelers: 4");
  expect(brief).toContain(
    "not a quote, booking, reservation, or confirmed itinerary",
  );
  await page.getByLabel("Number of travelers").fill("3");
  await expect(
    page.getByRole("link", { name: "Download your trip brief" }),
  ).toHaveCount(0);
});

test("mobile navigation and editorial disclosures work with the keyboard", async ({
  page,
}) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/");
  const menu = page.getByRole("button", { name: "Open navigation" });
  await menu.click();
  await expect(
    page.getByRole("navigation", { name: "Mobile", exact: true }),
  ).toBeVisible();
  await page.keyboard.press("Escape");
  await expect(menu).toBeFocused();
  await page.locator("#travel-guides summary").first().focus();
  await page.keyboard.press("Enter");
  await expect(page.locator("#travel-guides details").first()).toHaveAttribute(
    "open",
    "",
  );
});

for (const width of [320, 390, 768, 1440]) {
  test(`homepage reflows at ${width}px with enlarged text`, async ({
    page,
  }) => {
    await page.setViewportSize({ width, height: 900 });
    await page.goto("/", { waitUntil: "networkidle" });
    await page.evaluate(() => document.fonts.ready);
    for (const size of ["100%", "200%"]) {
      await page.evaluate((value) => {
        document.documentElement.style.fontSize = value;
      }, size);
      const reflow = await page.evaluate(() => ({
        fits: document.documentElement.scrollWidth <= window.innerWidth,
        scrollWidth: document.documentElement.scrollWidth,
        overflow: [...document.querySelectorAll("body *")]
          .filter((element) => {
            const rect = element.getBoundingClientRect();
            return (
              rect.width &&
              (rect.right > innerWidth ||
                rect.left < 0 ||
                (element instanceof HTMLElement &&
                  element.scrollWidth > element.clientWidth &&
                  getComputedStyle(element).display !== "inline"))
            );
          })
          .slice(0, 20)
          .map((element) => ({
            tag: element.tagName,
            text: element.textContent?.trim().slice(0, 100),
            classes: element.className,
            parent: element.parentElement?.outerHTML.slice(0, 240),
            scrollWidth: element.scrollWidth,
            clientWidth: element.clientWidth,
          })),
      }));
      expect(
        reflow.fits,
        `${width}px / ${size}, scroll ${reflow.scrollWidth}: ${JSON.stringify(reflow.overflow)}`,
      ).toBe(true);
      const box = await page
        .getByRole("button", { name: "Create my trip brief" })
        .boundingBox();
      expect(box?.height).toBeGreaterThanOrEqual(44);
    }
  });
}

test("desktop and mobile homepage meet automated accessibility checks", async ({
  page,
}) => {
  for (const width of [1440, 390]) {
    await page.setViewportSize({ width, height: 900 });
    await page.goto("/", { waitUntil: "networkidle" });
    const result = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21aa"])
      .analyze();
    expect(result.violations).toEqual([]);
  }
});

test("capture desktop/mobile implementation and original Stitch reference", async ({
  page,
}) => {
  test.setTimeout(90000);
  await mkdir("test-results/homepage", { recursive: true });
  for (const width of [1440, 390]) {
    await page.setViewportSize({ width, height: 900 });
    await page.goto("/", { waitUntil: "networkidle" });
    await page.evaluate(async () => {
      document.querySelectorAll("img").forEach((img) => {
        img.loading = "eager";
      });
      await Promise.all([...document.images].map((img) => img.decode()));
      await document.fonts.ready;
    });
    await page.screenshot({
      path: `test-results/homepage/actual-${width}.png`,
      fullPage: true,
    });
    if (width === 1440) {
      for (const id of [
        "destinations",
        "featured-packages",
        "trip-finder",
        "travel-guides",
        "for-agencies",
      ])
        await page.locator(`#${id}`).screenshot({
          path: `test-results/homepage/actual-${id}.png`,
          style: "header { visibility: hidden; }",
        });
    } else {
      for (const selector of [
        "main > section:first-child",
        "#trip-finder",
        "#travel-guides",
      ])
        await page.locator(selector).screenshot({
          path: `test-results/homepage/actual-${width}-${selector.includes("first-child") ? "hero" : selector.slice(1)}.png`,
          style: "header { visibility: hidden; }",
        });
    }
    await captureReference(page, width);
  }
});
