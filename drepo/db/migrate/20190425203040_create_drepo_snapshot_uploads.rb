# frozen_string_literal: true

class CreateDrepoSnapshotUploads < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  def change
    create_table :drepo_snapshot_uploads do |t|
      t.datetime_with_timezone :updated_at, null: false
      t.references :snapshot, index: true, foreign_key: { on_delete: :cascade, to_table: :drepo_snapshots }, unique: true
      t.text :export_file

      t.index :updated_at
    end
  end
end
