# Stack conventions (Bowerbird base)

Shared across Gilded Kestrel, Heritage Rampart, Resurgent Eagle patterns:

| Layer | Choice |
|-------|--------|
| Framework | Rails 8.1 |
| Assets | Propshaft + importmap |
| Interactivity | Turbo + Stimulus (Hotwire) |
| CSS | Product shell tokens + Tailwind utilities |
| Auth | Devise |
| DB | Postgres (DATABASE_URL), sqlite local fallback |
| Host | Railway (Dockerfile) |
| Jobs | Optional Sidekiq/Redis when needed (add per project) |
