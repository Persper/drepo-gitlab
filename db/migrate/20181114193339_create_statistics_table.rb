# frozen_string_literal: true

class CreateStatisticsTable < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :statistics, id: :bigserial do |t|
      t.references :project, null: false, foreign_key: { on_delete: :cascade }
      t.integer :key, null: false
      t.bigint :value, null: false

      t.index [:project_id, :key], unique: true
    end
  end
end
