# frozen_string_literal: true

class CreateDrepoTasks < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :drepo_tasks do |t|
      t.integer :author_id
      t.integer :source_id, null: false
      t.string :source_type, null: false
      t.string :type
      t.jsonb :parameter
      t.string :state
      t.text :state_reason
      t.integer :lock_version
      t.datetime_with_timezone :state_updated_at
      t.datetime_with_timezone :started_at
      t.datetime_with_timezone :finished_at

      t.timestamps_with_timezone null: false

      t.index [:source_id, :source_type], order: { created_at: :desc }
      t.index :author_id
    end
  end
end
