# frozen_string_literal: true

class CreateAiUsageEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_usage_events do |t|
      t.string :agent_name, null: false, default: "unknown"
      t.string :operation, null: false
      t.string :model
      t.string :response_id
      t.string :step
      t.integer :input_tokens, null: false, default: 0
      t.integer :output_tokens, null: false, default: 0
      t.integer :total_tokens, null: false, default: 0
      t.integer :duration_ms
      t.json :context, null: false, default: {}

      t.timestamps
    end

    add_index :ai_usage_events, :agent_name
    add_index :ai_usage_events, :created_at
    add_index :ai_usage_events, :step
  end
end
