# Design — example foundation

This base ships an **example** product UI (tokens, component classes, optional sidebar chrome).
It is a **starting suggestion**, not a rigid mandate.

Marker: `product-shell-v2` on `<html data-bb-design>` when using the example layout.

Primary CSS: **`/design/app.css`** (`public/design/app.css`).

## Stack (fixed)

- **Tailwind** utilities for layout/spacing (`preflight: false` when using CDN with this theme)
- A real theme stylesheet with design tokens (keep `/design/app.css` or an equivalent maintained theme)
- Hotwire (Turbo/Stimulus) for interactivity

## Layout is adaptive

Choose chrome that fits **this product**:

| Product type | Typical layout |
|--------------|----------------|
| Ops / admin tools | Sidebar + main (example shell works well) |
| Marketing / landing | Full-width marketing layout, minimal chrome |
| Marketplace / catalog | Top nav + content grids |
| Consumer / mobile-first | Bottom or top nav, card flows |
| Wizard / onboarding | Step chrome, no full product shell |

Do **not** blindly lock every screen to the example `app-shell` + sidebar if another structure serves the brief better.

## Example components (reuse when helpful)

| Need | Example |
|------|---------|
| Page title | `render "shared/page_header", title:, subtitle:, kicker:` |
| Card | `.card` + `.card-header` / `.section-title` |
| Metrics | `.metric-card` |
| Buttons | `.btn.btn-primary` / `.btn-secondary` / `.btn-ghost` |
| Tables | `.table-wrap` > `table.data` |
| Badges | `.badge` / `.badge-brand` / `.badge-up` |

You may invent app-specific layouts and components. Prefer polished, domain-appropriate UI over
template fidelity.

## Quality bar

- Production-worthy styling for this domain — never raw Rails scaffold HTML
- No placeholders, CSS class jargon as text, or Bowerbird/meta template language in customer UI
- Honor `design_feel` / design notes from the project brief when present
