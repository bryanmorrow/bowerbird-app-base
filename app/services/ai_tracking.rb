# frozen_string_literal: true

# Thread-local AI cost attribution for GrokClient calls.
#
#   AiTracking.scoped(agent_name: "landing_page", step: "generate") do
#     GrokClient.new.chat_json(...)
#   end
module AiTracking
  THREAD_KEY = :bowerbird_customer_ai_tracking_stack

  module_function

  def scoped(**attrs)
    stack << attrs.symbolize_keys
    yield
  ensure
    stack.pop
  end

  def merged_scope
    stack.reduce({}) { |acc, frame| acc.merge(frame) }
  end

  def record!(response_body:, operation:, duration_ms:, agent_name: nil, context: {}, model: nil)
    scope = merged_scope
    usage = extract_usage(response_body)
    return unless defined?(AiUsageEvent)

    AiUsageEvent.create!(
      agent_name: scope[:agent_name].presence || agent_name.presence || "unknown",
      operation: operation.to_s,
      model: model.presence || response_body.is_a?(Hash) && response_body["model"],
      response_id: response_body.is_a?(Hash) ? response_body["id"] : nil,
      input_tokens: usage[:input],
      output_tokens: usage[:output],
      total_tokens: usage[:total],
      duration_ms: duration_ms,
      step: scope[:step],
      context: stringify(scope.merge(context || {}))
    )
  rescue StandardError => e
    Rails.logger.warn("[AiTracking] #{e.class}: #{e.message}") if defined?(Rails)
    nil
  end

  def extract_usage(body)
    return { input: 0, output: 0, total: 0 } unless body.is_a?(Hash)

    u = body["usage"] || {}
    in_tok = (u["prompt_tokens"] || u["input_tokens"]).to_i
    out_tok = (u["completion_tokens"] || u["output_tokens"]).to_i
    total = (u["total_tokens"] || (in_tok + out_tok)).to_i
    { input: in_tok, output: out_tok, total: total }
  end

  def stringify(hash)
    hash.each_with_object({}) do |(k, v), memo|
      memo[k.to_s] = v.is_a?(Date) || v.is_a?(Time) ? v.iso8601 : v
    end
  end

  def stack
    Thread.current[THREAD_KEY] ||= []
  end
end
