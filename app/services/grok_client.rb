# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

# xAI Grok client for customer-app AI agents.
#
#   GrokClient.new.chat(prompt: "...", system: "...")
#   GrokClient.new.chat_json(prompt: "...", system: "...")
#
# API key: ENV["XAI_API_KEY"] (request via Bowerbird secrets as XAI_API_KEY).
# Prefer include AiAgent + build_tracked_client for named agents.
class GrokClient
  BASE_URL = "https://api.x.ai/v1"
  DEFAULT_MODEL = ENV.fetch("XAI_MODEL", "grok-3-mini")

  class Error < StandardError; end

  def initialize(api_key: ENV["XAI_API_KEY"], agent_name: nil, context: {})
    @api_key = api_key.to_s.strip
    @agent_name = agent_name
    @context = context.is_a?(Hash) ? context.symbolize_keys : {}
    raise Error, "XAI_API_KEY not set — request it via Bowerbird secrets" if @api_key.blank?
  end

  def chat(prompt:, system: nil, model: DEFAULT_MODEL)
    messages = []
    messages << { role: "system", content: system } if system.present?
    messages << { role: "user", content: prompt }

    body = request_chat(
      { model: model, messages: messages, temperature: 0.4 },
      operation: "chat",
      model: model
    )
    extract_message_text(body)
  end

  def chat_json(prompt:, system: nil, model: DEFAULT_MODEL)
    full_system = [system, "Respond with ONLY valid JSON. No markdown fences or commentary."].compact.join("\n\n")
    text = chat(prompt: prompt, system: full_system, model: model)
    parse_json(text)
  end

  private

  def request_chat(payload, operation:, model:)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    uri = URI.parse("#{BASE_URL}/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 20
    http.read_timeout = Integer(ENV.fetch("XAI_TIMEOUT_SEC", "120"))
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Authorization"] = "Bearer #{@api_key}"
    req["Content-Type"] = "application/json"
    req.body = JSON.generate(payload)
    response = http.request(req)
    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round

    parsed =
      begin
        JSON.parse(response.body.to_s)
      rescue JSON::ParserError
        response.body.to_s
      end

    unless response.is_a?(Net::HTTPSuccess)
      raise Error, "Grok API error (#{response.code}): #{response.body.to_s[0, 400]}"
    end

    if defined?(AiTracking)
      AiTracking.record!(
        response_body: parsed.is_a?(Hash) ? parsed : { "raw" => parsed.to_s },
        operation: operation,
        duration_ms: duration_ms,
        agent_name: @agent_name,
        model: model,
        context: @context
      )
    end

    parsed
  end

  def extract_message_text(body)
    return body if body.is_a?(String)

    if body.is_a?(Hash)
      choice = body.dig("choices", 0, "message", "content")
      return choice if choice.present?
      return body["output_text"] if body["output_text"].present?
    end

    body.to_s
  end

  def parse_json(text)
    cleaned = text.to_s.strip
    cleaned = cleaned.sub(/\A```(?:json)?\s*/i, "").sub(/\s*```\z/, "")
    JSON.parse(cleaned)
  rescue JSON::ParserError
    start = cleaned.index("{") || cleaned.index("[")
    ending = cleaned.rindex("}") || cleaned.rindex("]")
    raise Error, "Could not parse JSON from Grok: #{text.to_s[0, 200]}" unless start && ending

    JSON.parse(cleaned[start..ending])
  end
end
