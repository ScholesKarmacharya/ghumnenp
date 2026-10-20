// Manual visual-QA setup only. These reference-only CDN assets are never
// loaded by the app, production build, or database tooling.
import { mkdir, writeFile } from "node:fs/promises";

async function download(url) {
  const response = await fetch(url, {
    headers: {
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36",
    },
    signal: AbortSignal.timeout(30000),
  });
  if (!response.ok)
    throw new Error(`Reference QA asset failed: HTTP ${response.status}`);
  return response;
}

await mkdir("test-results/stitch-assets", { recursive: true });
const tailwind = await download("https://cdn.tailwindcss.com");
await writeFile(
  "test-results/stitch-assets/tailwind.js",
  Buffer.from(await tailwind.arrayBuffer()),
);
const css = await (
  await download(
    "https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200",
  )
).text();
const fontUrl = css.match(/url\((https:\/\/fonts\.gstatic\.com\/[^)]+)\)/)?.[1];
if (!fontUrl)
  throw new Error("Could not resolve original reference icon font.");
const font = Buffer.from(await (await download(fontUrl)).arrayBuffer());
if (font.subarray(0, 4).toString() !== "wOF2")
  throw new Error("Expected WOFF2 reference icon font.");
await writeFile("test-results/stitch-assets/material-symbols.woff2", font);
console.log(
  "Cached original Stitch CDN renderer and icon font for isolated screenshots. No app or database changes.",
);
