# AGENTS.md — Bowerbird app base

Managed customer application template. Expand this Rails app into the product
described in `docs/PROJECT_BRIEF.md` (written per project by Bowerbird).

## Stack (fixed — do not replace)

- **Rails 8.1** + Puma + Propshaft
- **Hotwire**: Turbo + Stimulus + importmap
- **Tailwind CSS** (utilities; `preflight: false` when using CDN) + **product shell** at `/design/app.css`
- **Devise** for authentication (User model)
- **Postgres** via `DATABASE_URL` (sqlite fallback if unset)
- **Railway** (`Dockerfile`, `railway.toml`)
- **Grok (xAI)** for product AI via `GrokClient` + `app/agents/*` (see `docs/AI.md`)

## Design system

- Layout: `app-shell` + `shared/_sidebar` + topbar + `app-content`
- Components: `.btn`, `.card`, `.metric-card`, `table.data`, `.badge`, `page_header`
- Theme: `public/design/app.css` linked as `/design/app.css` — **do not remove**
- Quality bar: modern ops desk (Gilded Kestrel–grade), never Rails scaffold HTML

## Auth

- Devise sessions; `authenticate_user!` when `AUTH_REQUIRED=true` (default)
- Owner admin is created at **runtime** by `GET /bowerbird/enter` (not via automatic `db:seed`)
- Preview auto-login: HMAC with `BOWERBIRD_PREVIEW_SECRET`
- Admin user management at `/users` when required

## AI agents (Grok)

When the product needs generative AI, use the **built-in Grok agent kit** — see `docs/AI.md`.

- `GrokClient` + `include AiAgent` + `app/agents/*_agent.rb`
- Secret: `XAI_API_KEY` (request with `REQUEST_SECRET: XAI_API_KEY — …`)
- **Real model calls** — never fake AI with string templates / static HTML assemblers
- Do not add OpenAI/Anthropic SDKs unless the customer explicitly asks

## Do

- Implement domain models, migrations, controllers, views on this shell
- Prefer calm **empty states** — do not seed demo/sample product data unless the customer asks
- Keep `/up` green
- Append notes to `docs/BUILD_LOG.md`
- For AI features: agents under `app/agents/`, `REQUEST_SECRET` for `XAI_API_KEY`

## Do not

- Switch frameworks, hosts, or auth systems without instruction
- Strip Devise, product shell, or `/design/app.css`
- Auto-seed demo/sample product data
- Auto-run `db:seed` on boot/deploy
- Ship placeholders ("coming soon"), CSS class jargon, or raw interview text in UI
- Commit secrets
- Pretend to use AI (template landing pages, hardcoded “generated” copy) when the customer asked for Grok/agents
