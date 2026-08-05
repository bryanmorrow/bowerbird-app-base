# frozen_string_literal: true

# Example Grok-powered agent. Copy this pattern for real product agents
# (e.g. LandingPageAgent, AdCreativeAgent). Delete or replace when unused.
#
#   ExampleCopyAgent.new.rewrite!(text: "…", tone: "professional")
#
# Requires ENV["XAI_API_KEY"] (customer secret via Bowerbird).
class ExampleCopyAgent
  include AiAgent

  def rewrite!(text:, tone: "clear and professional")
    ai_scope(step: "example_copy.rewrite") do
      build_tracked_client.chat(
        system: "You rewrite product UI copy. Be concise. No markdown fences.",
        prompt: "Tone: #{tone}\n\nRewrite:\n#{text}"
      )
    end
  end
end
