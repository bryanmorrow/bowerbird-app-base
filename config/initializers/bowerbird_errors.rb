# frozen_string_literal: true

# Report unhandled exceptions to the parent Bowerbird platform (Admin → Health).
#
# Env (set by Bowerbird on Railway):
#   BOWERBIRD_ERROR_REPORT_URL   — POST endpoint
#   BOWERBIRD_ERROR_REPORT_TOKEN — X-Bowerbird-Token
#   BOWERBIRD_APP_SLUG           — optional metadata
#
# No-op when URL/token blank (local dev without reporting).

module BowerbirdErrorReporter
  module_function

  def enabled?
    ENV["BOWERBIRD_ERROR_REPORT_URL"].to_s.strip.present? &&
      ENV["BOWERBIRD_ERROR_REPORT_TOKEN"].to_s.strip.present?
  end

  def report(exception, severity: "error", url: nil, http_status: nil, metadata: {})
    return false unless enabled?
    return false if exception.nil?

    require "net/http"
    require "uri"
    require "json"

    uri = URI.parse(ENV.fetch("BOWERBIRD_ERROR_REPORT_URL"))
    body = {
      message: "#{exception.class}: #{exception.message}".truncate(2000),
      kind: "exception",
      severity: severity.to_s,
      url: url,
      http_status: http_status,
      backtrace: Array(exception.backtrace).first(40),
      metadata: {
        "class" => exception.class.name,
        "app_slug" => ENV["BOWERBIRD_APP_SLUG"],
        "rails_env" => ENV["RAILS_ENV"]
      }.merge(metadata.to_h.stringify_keys).compact
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 3
    http.read_timeout = 5
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    req["X-Bowerbird-Token"] = ENV.fetch("BOWERBIRD_ERROR_REPORT_TOKEN")
    req["User-Agent"] = "BowerbirdErrorReporter/1.0"
    req.body = JSON.generate(body)
    http.request(req)
    true
  rescue StandardError => e
    Rails.logger.warn("[BowerbirdErrorReporter] #{e.class}: #{e.message}") if defined?(Rails)
    false
  end

  # Fire-and-forget so request path is not blocked.
  def report_async(exception, **opts)
    return unless enabled?

    Thread.new do
      report(exception, **opts)
    rescue StandardError
      nil
    end
  end
end

Rails.application.config.middleware.use(
  Class.new do
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Exception => e # rubocop:disable Lint/RescueException -- report then re-raise
      begin
        req = ActionDispatch::Request.new(env)
        BowerbirdErrorReporter.report_async(
          e,
          severity: e.is_a?(SystemExit) || e.is_a?(SignalException) ? "fatal" : "error",
          url: req.original_url.presence || req.fullpath,
          http_status: 500,
          metadata: {
            "method" => req.request_method,
            "path" => req.path,
            "controller" => env["action_controller.instance"]&.class&.name
          }
        )
      rescue StandardError
        nil
      end
      raise
    end
  end
)

# Rails 7.1+ error reporter (jobs, mailers, etc.)
if defined?(Rails.error) && Rails.error.respond_to?(:subscribe)
  Rails.error.subscribe(
    Class.new do
      def report(error, handled:, severity:, context:, source: nil)
        return if handled && severity.to_s == "info"

        BowerbirdErrorReporter.report_async(
          error,
          severity: severity.to_s.in?(%w[error fatal]) ? severity.to_s : "error",
          metadata: {
            "handled" => handled,
            "source" => source.to_s,
            "context" => context.is_a?(Hash) ? context.transform_keys(&:to_s).slice("controller", "job", "job_class") : {}
          }
        )
      rescue StandardError
        nil
      end
    end.new
  )
end
