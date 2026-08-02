# Auth

- **Devise** User with `name`, `role`, `admin`
- Seed owner from `BOWERBIRD_OWNER_EMAIL` / `NAME` / `PASSWORD`
- Preview: `GET /bowerbird/enter?email=&name=&exp=&sig=` HMAC-SHA256 of `email|name|exp`
- Secret: `BOWERBIRD_PREVIEW_SECRET`
- Toggle login wall: `AUTH_REQUIRED=true|false`
