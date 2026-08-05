# Auth

- **Devise** User with `name`, `role`, `admin`
- Owner is created at runtime via `/bowerbird/enter` (not auto-seeded product data)
- Preview: `GET /bowerbird/enter?email=&name=&exp=&sig=` HMAC-SHA256 of `email|name|exp`
- Secret: `BOWERBIRD_PREVIEW_SECRET`
- Toggle login wall: `AUTH_REQUIRED=true|false`
- **Login persists across redeploys:** session cookie `expire_after` 30 days + Devise
  `remember_me` on preview enter (requires stable `SECRET_KEY_BASE` on Railway)
