source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "propshaft"
gem "pg", "~> 1.1"
gem "sqlite3", ">= 2.1" # local / fallback when DATABASE_URL unset
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "devise", "~> 4.9"
# Action Cable production pubsub (config/cable.yml adapter: redis)
gem "redis", ">= 4.0.1"
gem "bootsnap", require: false
gem "thruster", require: false
gem "image_processing", "~> 2.0"
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "dotenv-rails"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end
