# Ghumne Stitch homepage implementation

Updated: 2026-10-20. Reference: the complete owner-supplied `supabase/stitch-reference/index.html` (86,690 bytes). No screenshot or separate stylesheet/image export accompanies it. The HTML, inline Tailwind configuration, all seven sections, font definitions and 16 image URLs were inspected before implementation. The reference file is unchanged and is never served by the application.

## Implemented behavior

The server homepage composes reusable hero/search, destinations, itinerary previews, Trip Finder, value pillars, stories and agency sections. Header/footer navigation points to existing routes or actual homepage anchors. Presentation data/contracts and pure normalization/filtering/brief logic live in `src/features/home`. Interactive filters and planning use small Client Components; the route, images and other sections remain Server Components.

| Surface      | Working behavior                                                                                                                                 | Data boundary                                                                                                     |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| Hero/search  | Native GET search, case-insensitive destination filtering, starting-hub/season/group preference forwarding                                       | Editorial previews only; does not imply agency availability                                                       |
| Destinations | Five original-photo cards and planning links; useful no-results state and clear-search recovery                                                  | No fabricated package counts or destination detail routes                                                         |
| Journeys     | Six explicitly illustrative itinerary cards, combined region/duration/culture filters, filter reset and no-results state                         | No agency identities, prices, reviews, verified badges, inclusions or available dates                             |
| Trip Finder  | Five preference steps, exact traveler count, total-group budget preference, generated text brief and real download; stale output clears on edits | No quote, booking, live match, account saving or network submission                                               |
| Stories      | Original lead/three-thumbnail composition and keyboard-operable preview disclosures                                                              | Full sourced articles remain in preparation; no fake authors or published dates                                   |
| Agency panel | Publishing-model explanation and functioning in-page navigation                                                                                  | Subscription-aware packages are a planned integration; onboarding, payments and traveler services are unavailable |

Existing loading, public error/not-found and safe recovery boundaries remain. Local search/filter empty states are implemented. This page performs no remote data fetch requiring a simulated loader/error state. Future real queries must adopt the existing loading/empty/error conventions and public-safe typed adapters.

## Visual comparison

Rendered the original HTML and production homepage at 1440px and 390px, using the same locally cached source photos/fonts to avoid network variation. Full-page and desktop section screenshots are in `test-results/homepage`; selected mobile section captures are included. Reference rendering is isolated test code, not a product route. Section captures hide the sticky/fixed header solely to prevent it obscuring the captured section; full-page captures retain the header.

The cinematic Himalayan hero, exact heading, Playfair/Jakarta pairing, horizontal hierarchy, 1360px container, 48px desktop gutters, five-card destination bento (7/5 then 4/4/4), six-card three-column journey grid, five-step white planning panel, four principles, 7/5 story split, 7/5 forest agency panel and five-column footer follow the source. Photos retain the original ordering and centered cover crops.

Significant visible differences are deliberate and limited to the owner's palette/truthfulness requirements and responsive/accessibility corrections:

| Reference                                                                        | Implementation / reason                                                                                                                                                                                                       |
| -------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Mint backgrounds and deeper green source palette                                 | Exact approved Forest `#173D38`, Sand `#D5C6AD`, Terracotta `#C26A43`, Ivory `#F6F2E9`, Charcoal `#26342F`; pale insets mix sand/ivory. Terracotta accents meet their decorative role; normal-size links use readable colors. |
| Fixed header, sign-in/avatar and listing links with `href="#"`                   | Sticky header and working section/mobile navigation; future auth/listing controls are omitted. Hero plus header retains the 942px desktop stack, but the photo starts below the header.                                       |
| Hero search overflows/clips because of the export's grid/overflow rules          | All five controls fit on desktop and stack/reflow on mobile. A short explanatory label identifies preview search.                                                                                                             |
| Unverified package counts, agencies, prices, badges and protections              | Removed; visible preview/price-unpublished labels and truthful copy add some height. No fabricated stock is used to populate a marketplace.                                                                                   |
| Per-person budget and categorical traveler controls; pretend 42 matches          | Total-group preference and exact traveler count; destination/season fields carry search inputs; a local brief/download replaces unsupported matching. This panel is taller than the static source.                            |
| Payment escrow, licensed-agency, protection and commission promises              | Future publishing-process copy, without operational or accreditation claims. No payment/contact/deck/signup interaction is invented.                                                                                          |
| Published story authors/dates, full-guide links and source-less current guidance | Clearly labeled editorial previews with native disclosures. No medical, permit or current legal guidance is asserted.                                                                                                         |
| Full Material Symbols font                                                       | Small inline SVG icons with equivalent visual roles and decorative accessibility semantics.                                                                                                                                   |
| Desktop-centric fixed source layouts on small screens                            | Disclosure navigation, single-column destinations/journeys, wrapping stories/actions and responsive Finder choices; content remains usable with doubled text down to 320px.                                                   |

The result is visually close in section composition and typography, not a pixel-identical copy of unsupported source content. No additional gradients, motion effects or decorative sections were introduced; the photo scrims and subtle agency contour are from the source.

## Assets, SEO and performance

All 16 source photo URLs were accessible; **no replacement photographs** were needed. `public/images/home/sources.json` records every original URL, description, output path and byte count. Existing sharp optimizes them to approximately 600KB total WebP without enlarging the originals. Most originals are only 512px wide (hero 512×217): large-screen softness is inherited from the export. The heritage image embeds tiny interface strips along its edges in the source itself; a clean higher-resolution original would improve it without changing composition. The source does not include independent image-license metadata; no additional license claim is made here.

Playfair Display regular/italic and Plus Jakarta Sans variable WOFF2 faces are hosted locally via `next/font/local`, with OFL license files retained. Images use static imports, `next/image`, declared responsive sizes, stable containers and blur placeholders. Hero fetch priority is high/eager; remaining images are lazy by default. No Google Fonts, image-CDN, Supabase or analytics request is made by the production homepage. No dependency or remote image allowlist was added. GET filtering renders on the server and therefore keeps `/` dynamic rather than statically cached.

The page has one descriptive `h1`, ordered section headings, English document language, dedicated title/description/Open Graph copy, meaningful photo alt text, labels/fieldsets, native controls, visible focus and a skip link. No fake Offer/Review structured data or invented production canonical domain is supplied. Automated scans do not replace manual assistive-technology or production Core Web Vitals assessment.

## Validation

Passed: formatting, zero-warning lint, strict TypeScript, 121 unit tests, production build; homepage browser suite 11/11, existing feedback 6/6 and production smoke 1/1. Desktop/mobile axe scans report zero violations. Reflow passes at 320/390/768/1440px with normal and 200% text. Detailed results are recorded in `PROGRESS.md`. Commands:

```sh
npm run check
npm run prepare:reference-qa
npm run test:home
npm run test:feedback
npm run test:feedback:production
```

The reference-QA preparation command only downloads the public renderer/icon font used by the original HTML into ignored test output. Run once, or again after clearing `test-results/stitch-assets`. It is not part of app builds or database work. On Windows, browser tests use installed Edge and need permission to clean up their own temporary localhost server. No Docker/WSL is involved.

Existing tests retain their behavior; the production smoke test's homepage heading expectation was updated to the approved headline. Added ten planning-unit cases and eleven homepage browser cases for search/preferences, combined filters/empty recovery, download content, stale-output handling, keyboard navigation, four viewport widths at normal/200% text, automated desktop/mobile accessibility, source-asset loading and screenshot capture.

## Remaining integrations

- Apply the separately approved hosted-database workflow, execute the prepared RLS/pgTAP tests and generate actual schema types before enabling real package queries. Database security is **not verified** by homepage tests.
- Implement eligible public package adapters and shared matching/whole-group quotes using approved agencies, effective subscriptions, reviewed revisions, price and availability policies. Keep organic matches independent of paid promotion and label any future sponsorship.
- Add destination/package detail routes, reviewed full guides, authenticated saved plans and secure agency onboarding/inquiries before linking those operations.
- Confirm production image rights and obtain higher-resolution originals when available; assess production performance and assistive-technology behavior before release.

No Supabase configuration, credentials, SQL migration or database test was modified for this homepage. No SQL was applied, service deployed, billing activated or other Supabase project accessed.
