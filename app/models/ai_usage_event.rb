# frozen_string_literal: true

# Optional usage log for Grok / agent calls (Admin AI cost dashboards can extend this).
class AiUsageEvent < ApplicationRecord
  validates :agent_name, :operation, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_agent, ->(name) { where(agent_name: name) }
end
