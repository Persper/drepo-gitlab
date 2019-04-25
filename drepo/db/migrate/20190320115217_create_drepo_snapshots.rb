# frozen_string_literal: true

# rubocop:disable Migration/Timestamps
class CreateDrepoSnapshots < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  def change
    create_table :drepo_snapshots do |t|
      t.integer :target_id
      t.string :target_type
      t.jsonb :repo_refs
      t.string :state
      t.integer :snapped_by_id
      t.datetime :snapped_at
      t.integer :chained_by_id
      t.datetime :chained_at

      t.timestamps null: false

      t.index [:target_id, :target_type], order: { created_at: :desc }
      t.index :snapped_at
      t.index :chained_at
    end
  end
end
