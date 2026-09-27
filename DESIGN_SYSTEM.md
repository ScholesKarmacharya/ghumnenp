# Ghumne design system

Authority: master specification section 4. Implementation tokens live in `src/app/tokens.css` and are available as Tailwind utilities and CSS variables. This document records practical defaults where the specification intentionally leaves values open.

## Color roles

Use warm neutral backgrounds, forest-green primary actions, and a restrained clay accent. Keep travel images as the visual focus when destination content is implemented. Use semantic tokens instead of introducing a new palette in each feature.

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
- `max-w-reading`: 65 characters for sustained text.
- `rounded-control`: 12px for controls; `rounded-card`: 20px for content cards; `rounded-pill`: tags only.
- `shadow-card`: subtle elevation. Prefer spacing and borders to stacked shadows.
- Default transition: 150ms for simple color/state feedback. Global reduced-motion rules shorten animation and transitions.

## Typography

Use the local Segoe UI / Noto Sans / Arial system stack. No remote font is required to render or build the app. Body text is 16px with a 1.65 line height; supporting text is 14px minimum. Preserve browser text scaling and never give text containers a fixed height.

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

Reusable controls follow in TASK-010 onward. Product pages will compose these primitives in Phase 4; do not invent destination data or routes for a component preview.
