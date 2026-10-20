# Ghumne design system

Authority: master specification section 4. Implementation tokens live in `src/app/tokens.css` and are available as Tailwind utilities and CSS variables. This document records practical defaults where the specification intentionally leaves values open.

## Color roles

Use warm neutral backgrounds, forest-green primary actions, and a restrained clay accent. Keep travel images as the visual focus when destination content is implemented. Use semantic tokens instead of introducing a new palette in each feature.

The approved V1 palette is Forest Green `#173D38`, Sand `#D5C6AD`, Terracotta `#C26A43`, Warm Ivory `#F6F2E9`, and Deep Charcoal `#26342F`. Named brand tokens feed the existing semantic roles: forest primary/focus, ivory page background, charcoal foreground, sand muted surfaces/decorative borders, and terracotta accents. White control/card surfaces and the existing semantic status colors remain available. Primary hover uses a darker forest shade.

Forest text on ivory has 10.67:1 contrast; charcoal on ivory 11.64:1; charcoal on sand 7.75:1; supporting text on ivory 5.84:1. Terracotta on ivory/white has only 3.46:1/3.86:1 contrast: use it for decorative accents or sufficiently large text, not ordinary text or white-text standard-size buttons. The existing brand dot is decorative. Keep strong control borders and explicit focus indicators; sand borders are decorative only.

| Role                   | Utility examples                                           | Usage                                                      |
| ---------------------- | ---------------------------------------------------------- | ---------------------------------------------------------- |
| Page / card / inset    | `bg-background`, `bg-surface`, `bg-surface-muted`          | Page canvas, content surfaces, secondary regions           |
| Main / supporting text | `text-foreground`, `text-muted`                            | Main content and descriptions; muted text remains readable |
| Primary action         | `bg-primary text-on-primary`, `hover:bg-primary-hover`     | Main action in a section                                   |
| Secondary accent       | `text-accent`                                              | Small editorial accents; not a second primary action       |
| Borders                | `border-border`, `border-border-strong`                    | Decorative separation versus input/control boundaries      |
| Focus                  | `outline-focus`                                            | Visible keyboard focus; offset it from the component       |
| Status                 | `text-success`, `text-warning`, `text-danger`, `text-info` | Pair with the matching `bg-*-surface` and a text label     |

Never use color alone to convey error, selection, or verification. Use strong borders for controls; the softer border is only decorative. Status foreground/surface pairs and normal text must meet 4.5:1 contrast. Control boundaries and focus indicators must meet 3:1 against adjacent surfaces.

## Spacing and shape

- Base spacing unit: 4px. Prefer 8, 12, 16, 24, 32, 48, and 64px for layout rhythm.
- `min-h-control` / `min-w-control`: 44px minimum target for interactive controls.
- `px-gutter`: 24px horizontal content padding; keep content within `max-w-page` (1200px).
- The approved homepage uses `max-w-home` (1360px), 48px desktop/20px mobile gutters, 16px destination-grid gaps, and smaller reference-shaped cards. Keep the existing shared primitive defaults for other surfaces.
- `max-w-reading`: 65 characters for sustained text.
- `rounded-control`: 12px for controls; `rounded-card`: 20px for content cards; `rounded-pill`: tags only.
- `shadow-card`: subtle elevation. Prefer spacing and borders to stacked shadows.
- Default transition: 150ms for simple color/state feedback. Global reduced-motion rules shorten animation and transitions.

## Typography

Use the reference's locally hosted Plus Jakarta Sans for body/control text and Playfair Display for editorial headings, including the italic hero accent. `next/font/local` supplies variable font faces with swap and system fallbacks; OFL licenses are alongside the WOFF2 files in `src/app/fonts`. Rendering/builds do not fetch Google Fonts. Body text is 16px with a 1.65 line height; supporting copy is 14px, with 12px reference-style short labels. Homepage headings scale from 36 to 56px for the hero and 28 to 40px for sections. Preserve browser text scaling and never give text containers a fixed height.

| Utility           | Size at the default root font   | Use                            |
| ----------------- | ------------------------------- | ------------------------------ |
| `text-display`    | Fluid 40–60px, 1.1 line height  | One primary hero heading       |
| `text-title`      | Fluid 32–48px, 1.15 line height | Page title                     |
| `text-heading`    | 24px, 1.3 line height           | Section heading                |
| `text-subheading` | 18px, 1.4 line height           | Card/subsection title          |
| `text-lead`       | 18px, 1.65 line height          | Short introductory copy        |
| `text-body`       | 16px, 1.65 line height          | Body copy and form fields      |
| `text-caption`    | 14px, 1.5 line height           | Supporting labels and metadata |

Use one `h1` per page and a meaningful heading order. Choose the semantic element for the document structure; utilities can adjust its visual size. Keep sustained prose within `max-w-reading` (65ch), use sentence case, and let long text wrap. Dates, prices, and other estimates still need their uncertainty labels.

## Scope

### Buttons and links

`Button` uses native button semantics, defaults to `type="button"`, and supports primary, secondary, ghost, and danger variants. Use `type="submit"` explicitly in forms. `isLoading` disables activation and supplies a visible `loadingLabel` plus `aria-busy`. Keep the label specific to the operation. Native `disabled` prevents activation; it is not a substitute for server-side authorization.

Use `ButtonLink` for navigation styled as an action and `TextLink` for inline navigation. Links stay links, without a pretend disabled state. New-tab links retain supplied `rel` values and add `noopener noreferrer`; include the new-tab behavior in their label/context. Standalone actions have a 44px minimum target; inline text links retain normal text flow.

Run `npm run dev` and open `/ui-preview` to inspect controls. This route returns 404 outside development, includes no live data, and is excluded from indexing. Product pages will compose these primitives in Phase 4.

### Form controls

`Input`, `Select`, `Textarea`, `Checkbox`, and `Radio` require a unique `id` and visible `label`. They connect optional `hint` and `error` text through `aria-describedby` while preserving additional caller descriptions. Errors set `aria-invalid` and render an alert with text. Native types, required/min/max/pattern attributes, disabled state, names, events, and React 19 refs pass through.

Use actual input types (`email`, `number`, `date`, etc.) and `autoComplete` where appropriate. Group related radios/checkboxes in a `fieldset` with a `legend`; radios in one group share a name. Checkbox/radio labels provide the 44px target. Native selects retain platform keyboard behavior. Textareas resize vertically. Client/browser validation helps users but never replaces server-side Zod validation.

### Cards and badges

`Card` defaults to an article and can render a section or div to match its content. Use an actual heading and `aria-labelledby` for meaningful cards. `CardHeader`, `CardContent`, and `CardFooter` provide consistent spacing; actions remain explicit links/buttons so cards do not introduce nested interactive targets. Domain card content and responsive images belong to their feature tasks.

`Badge` provides neutral, primary, success, warning, danger, and info tones. Every badge requires a text label. Badges are noninteractive; use a real button for selectable tags. Status wording must reflect actual data, not imply unverified quality or guaranteed availability.

### Header and navigation

The public layout includes `SiteHeader`, a skip-to-content link, and a compact brand link. Each public page must provide `<main id="main-content" tabIndex={-1}>`. Navigation uses existing routes from `components/layout/navigation.ts`; add links with their completed features.

Below 1024px, a disclosure button controls the mobile navigation. It supports Tab, Escape with focus restoration, outside clicks, link selection, and resets when the route or desktop breakpoint changes. It is ordinary site navigation, not an ARIA menu or modal. Desktop and mobile navigation are never simultaneously visible/focusable. Current-page links expose `aria-current="page"`; homepage section links use their real anchors.

### Footer

`SiteFooter` is a Server Component with the shared brand, product positioning, copyright, and a separately named navigation landmark. It wraps into one column on small screens and sits after content using the public layout's minimum viewport height. Add policy/contact links only when their real content and routes are available; never invent addresses or legal claims.

### Loading and feedback

Use `LoadingState` for a named loading status and decorative skeletons; skeletons are hidden from assistive technology and stop pulsing for reduced-motion users. Use `EmptyState` for a clear explanation and a relevant next action. Use `ErrorState` for a safe error message and a real recovery action; never pass database errors, stack traces, or tokens into user-facing copy. `SuccessMessage` announces a completed action politely.

Choose `headingAs` to preserve the page's heading order. Public loading/error conventions provide a main landmark; the 404 page offers a working home link, and the global error boundary provides its own document shell. Error boundaries call Next.js's reset function and do not render the supplied error object. Actual feature data loading/mutation flows must adopt these primitives when those features are implemented.
