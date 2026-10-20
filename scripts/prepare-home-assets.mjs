// Explicit, one-off source preparation. Never called by builds or app requests.
import { mkdir, readFile, writeFile } from "node:fs/promises";
import sharp from "sharp";

const reference = await readFile(
  "supabase/stitch-reference/index.html",
  "utf8",
);
const names = [
  "hero",
  "mustang",
  "pokhara",
  "chitwan",
  "rara",
  "bandipur",
  "overland",
  "annapurna",
  "canoe",
  "camping",
  "heritage",
  "helicopter",
  "dolpo-guide",
  "monsoon-guide",
  "teahouse-guide",
  "permits-guide",
];
const sources = [
  ...reference.matchAll(
    /data-alt="([^"]*)"\s+style="background-image: url\('([^']+)'\)"/g,
  ),
];
if (sources.length !== names.length)
  throw new Error("Review changed reference images before preparing assets.");
await mkdir("public/images/home", { recursive: true });
await mkdir("src/app/fonts", { recursive: true });
async function download(url) {
  const response = await fetch(url, { signal: AbortSignal.timeout(30000) });
  if (!response.ok)
    throw new Error(`Asset request failed: HTTP ${response.status}`);
  return Buffer.from(await response.arrayBuffer());
}
const manifest = [];
// Bound concurrency to four downloads; no credentials or environment files used.
for (let start = 0; start < sources.length; start += 4) {
  await Promise.all(
    sources.slice(start, start + 4).map(async (match, offset) => {
      const index = start + offset;
      const url = new URL(match[2]);
      if (
        url.protocol !== "https:" ||
        url.hostname !== "lh3.googleusercontent.com" ||
        !url.pathname.startsWith("/aida-public/")
      )
        throw new Error("Unexpected reference image host.");
      const data = await download(url);
      const output = await sharp(data)
        .resize({
          width: index === 0 ? 1600 : index > 12 ? 400 : 1200,
          withoutEnlargement: true,
        })
        .webp({ quality: 85 })
        .toBuffer();
      const path = `public/images/home/${names[index]}.webp`;
      await writeFile(path, output);
      manifest[index] = {
        file: path,
        source: match[2],
        referenceDescription: match[1],
        bytes: output.length,
      };
      console.log(`${names[index]}: ${output.length} bytes`);
    }),
  );
}
const families = [
  {
    family: "Playfair Display",
    query: "Playfair+Display:wght@400..900",
    file: "playfair-display.woff2",
  },
  {
    family: "Playfair Display Italic",
    query: "Playfair+Display:ital,wght@1,400..900",
    file: "playfair-display-italic.woff2",
  },
  {
    family: "Plus Jakarta Sans",
    query: "Plus+Jakarta+Sans:wght@300..800",
    file: "plus-jakarta-sans.woff2",
  },
];
for (const family of families) {
  const response = await fetch(
    `https://fonts.googleapis.com/css2?family=${family.query}&display=swap`,
    {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36",
      },
      signal: AbortSignal.timeout(30000),
    },
  );
  if (!response.ok) throw new Error("Reference font stylesheet unavailable.");
  const css = await response.text();
  const faces = css.split("/* latin */").at(-1);
  const url = faces.match(/url\((https:\/\/fonts\.gstatic\.com\/[^)]+)\)/)?.[1];
  if (!url)
    throw new Error("Could not resolve the reference font's Latin face.");
  const font = await download(url);
  if (font.subarray(0, 4).toString() !== "wOF2")
    throw new Error("Expected an optimized WOFF2 font face.");
  await writeFile(`src/app/fonts/${family.file}`, font);
  console.log(`Font: ${family.family}`);
}
for (const family of ["playfairdisplay", "plusjakartasans"]) {
  await writeFile(
    `src/app/fonts/${family}-OFL.txt`,
    await download(
      `https://raw.githubusercontent.com/google/fonts/main/ofl/${family}/OFL.txt`,
    ),
  );
}
await writeFile(
  "public/images/home/sources.json",
  JSON.stringify(manifest, null, 2) + "\n",
);
console.log(
  "Prepared all 16 original reference images and three locally served font faces. No replacements.",
);
