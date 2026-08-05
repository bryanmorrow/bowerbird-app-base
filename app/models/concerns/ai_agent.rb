# frozen_string_literal: true

# Include in agent / service classes for named Grok agents + cost tracking.
#
#   class LandingPageAgent
#     include AiAgent
#
#     def generate!(...)
#       ai_scope(step: "landing_page.generate") do
#         build_tracked_client.chat_json(prompt: ..., system: ...)
#       end
#     end
#   end
#
# Put agents under app/agents/*_agent.rb (or app/services/*_agent.rb).
module AiAgent
  extend ActiveSupport::Concern

  class_methods do
    def ai_agent_name
      # LandingPageAgent → "landing_page"
      name.demodulize.delete_suffix("Agent").underscore
    end
  end

  def ai_scope(**extra, &block)
    attrs = { agent_name: self.class.ai_agent_name }.merge(extra.compact)
    AiTracking.scoped(**attrs, &block)
  end

  def build_tracked_client(**context)
    agent = context.delete(:agent_name) || self.class.ai_agent_name
    GrokClient.new(agent_name: agent, context: context.compact)
  end
end
