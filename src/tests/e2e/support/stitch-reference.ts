import type { Page } from "@playwright/test";
import { readFile } from "node:fs/promises";

async function referenceAsset(file: string) {
  return readFile(`test-results/stitch-assets/${file}`).catch(() => {
    throw new Error(
      "Run npm run prepare:reference-qa once before capturing the Stitch reference.",
    );
  });
}

// Isolated visual QA only. The original owner-supplied HTML is never served by
// the application or evaluated in its authenticated browser context.
export async function captureReference(page: Page, width: number) {
  const html = await readFile("supabase/stitch-reference/index.html", "utf8");
  const images: { file: string; source: string }[] = JSON.parse(
    await readFile("public/images/home/sources.json", "utf8"),
  );
  const font = async (name: string) =>
    (await readFile(`src/app/fonts/${name}.woff2`)).toString("base64");
  const symbols = (await referenceAsset("material-symbols.woff2")).toString(
    "base64",
  );
  const css = `
    @font-face{font-family:'Plus Jakarta Sans';font-weight:300 800;src:url(data:font/woff2;base64,${await font("plus-jakarta-sans")}) format('woff2');}
    @font-face{font-family:'Playfair Display';font-weight:400 900;src:url(data:font/woff2;base64,${await font("playfair-display")}) format('woff2');}
    @font-face{font-family:'Playfair Display';font-weight:400 900;font-style:italic;src:url(data:font/woff2;base64,${await font("playfair-display-italic")}) format('woff2');}
    @font-face{font-family:'Material Symbols Outlined';font-weight:100 700;src:url(data:font/woff2;base64,${symbols}) format('woff2');}
    .material-symbols-outlined{font-family:'Material Symbols Outlined';font-weight:normal;font-style:normal;font-size:24px;line-height:1;letter-spacing:normal;text-transform:none;display:inline-block;white-space:nowrap;word-wrap:normal;direction:ltr;font-feature-settings:'liga';-webkit-font-smoothing:antialiased;}
  `;
  await page.route("https://cdn.tailwindcss.com/**", async (route) =>
    route.fulfill({
      body: await referenceAsset("tailwind.js"),
      contentType: "application/javascript",
    }),
  );
  await page.route("https://fonts.googleapis.com/**", (route) =>
    route.fulfill({ body: css, contentType: "text/css" }),
  );
  await page.route("https://lh3.googleusercontent.com/**", async (route) => {
    const image = images.find(
      (image) => image.source === route.request().url(),
    );
    if (!image) throw new Error("Unexpected reference image requested");
    await route.fulfill({ path: image.file, contentType: "image/webp" });
  });
  await page.setContent(html, { waitUntil: "networkidle" });
  await page.waitForFunction(
    () =>
      getComputedStyle(document.body).backgroundColor === "rgb(237, 253, 245)",
  );
  await page.evaluate(() => document.fonts.ready);
  await page.screenshot({
    path: `test-results/homepage/reference-${width}.png`,
    fullPage: true,
  });
  if (width === 1440) {
    const names = [
      "hero",
      "destinations",
      "featured-packages",
      "trip-finder",
      "principles",
      "travel-guides",
      "for-agencies",
    ];
    for (let index = 0; index < names.length; index++)
      await page
        .locator("main section")
        .nth(index)
        .screenshot({
          path: `test-results/homepage/reference-${names[index]}.png`,
          style: "header { visibility: hidden; }",
        });
  }
  await page.unrouteAll({ behavior: "wait" });
}
