ARG RUBY_VERSION=3.4.2
FROM ruby:$RUBY_VERSION-slim AS base
WORKDIR /rails
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libpq5 libyaml-0-2 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
ENV RAILS_ENV=production \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test"

FROM base AS build
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libsqlite3-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
COPY Gemfile Gemfile.lock* ./
RUN bundle install
COPY . .
ENV SECRET_KEY_BASE=precompile_placeholder_not_used_at_runtime
RUN bundle exec rails assets:precompile 2>/dev/null || true
RUN mkdir -p public/design && \
    if [ -f app/assets/stylesheets/application.css ] && [ ! -s public/design/app.css ]; then \
      cp app/assets/stylesheets/application.css public/design/app.css; \
    fi

FROM base
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p /rails/tmp /rails/log /rails/storage && \
    chown -R rails:rails /rails
USER 1000:1000
COPY --chown=rails:rails --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=rails:rails --from=build /rails /rails
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
