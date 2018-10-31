# frozen_string_literal: true

class CreateCiWorkspacesTable < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :ci_workspaces, id: :bigserial do |t|
      t.references :project, index: true,
                             foreign_key: { on_delete: :cascade },
                             null: false
      t.timestamps_with_timezone null: false
    end
  end
end
