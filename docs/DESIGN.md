# Design system

Marker: `product-shell-v2` on `<html data-bb-design>`.

Primary CSS: **`/design/app.css`** (`public/design/app.css`).

## Components

| Need | Use |
|------|-----|
| Page title | `render "shared/page_header", title:, subtitle:, kicker:` |
| Card | `.card` + `.card-header` / `.section-title` |
| Metrics | `.metric-card` |
| Buttons | `.btn.btn-primary` / `.btn-secondary` / `.btn-ghost` |
| Tables | `.table-wrap` > `table.data` |
| Badges | `.badge` / `.badge-brand` / `.badge-up` |

Build every feature screen on this shell. Do not ship unstyled scaffold HTML.
