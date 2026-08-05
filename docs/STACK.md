# Stack conventions (Bowerbird base)

Shared across Gilded Kestrel, Heritage Rampart, Resurgent Eagle, Bowerbird, Corvus patterns:

| Layer | Choice |
|-------|--------|
| Framework | Rails 8.1 |
| Assets | Propshaft + importmap |
| Interactivity | Turbo + Stimulus (Hotwire) — **fully wired by default** |
| CSS | Example theme tokens + Tailwind utilities (layout adaptive per product) |
| Auth | Devise |
| DB | Postgres (DATABASE_URL), sqlite local fallback |
| Host | Railway (Dockerfile) |
| Jobs | Optional Sidekiq/Redis when needed (add per project) |

## Hotwire wiring checklist

These must exist and work even if the MVP does not use client interactivity yet:

1. **Gems** in `Gemfile`: `importmap-rails`, `turbo-rails`, `stimulus-rails`
2. **`config/importmap.rb`** pins:
   - `application`
   - `@hotwired/turbo-rails` → `turbo.min.js` (from gem)
   - `@hotwired/stimulus` → `stimulus.min.js` (from gem)
   - `@hotwired/stimulus-loading` → `stimulus-loading.js` (from gem)
   - `pin_all_from "app/javascript/controllers", under: "controllers"`
3. **`app/javascript/application.js`**:
   ```js
   import "@hotwired/turbo-rails"
   import "controllers"
   ```
4. **Controllers bootstrap**:
   - `app/javascript/controllers/application.js` — `Application.start()`
   - `app/javascript/controllers/index.js` — `eagerLoadControllersFrom("controllers", application)`
   - example: `sidebar_controller.js`, `hello_controller.js`
5. **Layouts** (`application`, `auth`, and any custom HTML layout):
   ```erb
   <%= javascript_importmap_tags %>
   ```
6. **`bin/importmap`** present for `bin/importmap pin …`

Turbo/Stimulus JS is provided by the gems (no `vendor/javascript` copy required unless you pin CDN packages).
