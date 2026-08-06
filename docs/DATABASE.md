# Database (Bowerbird foundation)

Marker: `bowerbird-database-v1`

## Production (required)

| Setting | Value |
|---------|--------|
| Engine | **PostgreSQL** |
| Connection | `ENV["DATABASE_URL"]` |
| Hosting | Railway **Postgres** service with a **persistent volume** |
| Web wiring | `DATABASE_URL=${{Postgres.DATABASE_URL}}` on the web service |

Production **must not** use SQLite or any path under `storage/` in the container.
That filesystem is ephemeral — every redeploy would wipe customer data.

Bowerbird’s **DatabaseFoundation** attaches Postgres and wires `DATABASE_URL` when the
app is provisioned (and re-checks on Railway reconcile).

## Local development

SQLite under `storage/development.sqlite3` is fine for smoke tests only.

## Boot / deploy

- `bin/docker-entrypoint` runs `db:prepare` only (never `db:drop`, `db:reset`, or forced `schema:load`).
- Production boot **exits** if `DATABASE_URL` is missing or points at sqlite.

## Railway checklist

1. Service **Postgres** exists (with volume on `/var/lib/postgresql/data`).
2. Web service has `DATABASE_URL=${{Postgres.DATABASE_URL}}`.
3. `RAILS_ENV=production` and `SECRET_KEY_BASE` / `RAILS_MASTER_KEY` are set.

## Rules for builders / AI

- Never switch production to SQLite.
- Never run destructive DB rake tasks on deploy.
- Prefer additive migrations; do not recreate tables that already exist.
- Do not auto-seed demo product data unless the customer asks.
