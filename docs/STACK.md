# Stack conventions (Bowerbird base)

Shared across Gilded Kestrel, Heritage Rampart, Resurgent Eagle patterns:

| Layer | Choice |
|-------|--------|
| Framework | Rails 8.1 |
| Assets | Propshaft + importmap |
| Interactivity | Turbo + Stimulus (Hotwire) |
| CSS | Example theme tokens + Tailwind utilities (layout adaptive per product) |
| Auth | Devise |
| DB | Postgres (DATABASE_URL), sqlite local fallback |
| Host | Railway (Dockerfile) |
| Jobs | Optional Sidekiq/Redis when needed (add per project) |
