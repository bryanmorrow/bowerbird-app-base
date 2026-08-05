# frozen_string_literal: true

# Durable login cookies so owners stay signed in across Railway redeploys.
# Browser "session" cookies (no expire_after) are easy to drop when the app
# restarts or the tab recovers after a deploy blip; a long-lived signed cookie
# keeps Devise sessions + remember tokens valid as long as SECRET_KEY_BASE is stable.
Rails.application.config.session_store :cookie_store,
  key: "_bowerbird_app_session",
  expire_after: 30.days,
  same_site: :lax,
  secure: Rails.env.production?,
  httponly: true
