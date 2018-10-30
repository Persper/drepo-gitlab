# frozen_string_literal: true

class CreateCiContextsTable < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :ci_contexts, id: :bigserial do |t|
      t.references :project, index: true,
                             foreign_key: { on_delete: :cascade },
                             null: false
      t.timestamps_with_timezone null: false
    end
  end
end
