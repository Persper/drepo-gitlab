# frozen_string_literal: true

# rubocop:disable Migration/RemoveColumn
# rubocop:disable Migration/RemoveIndex
# rubocop:disable Migration/AddIndex
class RenameDrepoSnapshotsAndDrepoSnapshotUploads < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = true
  DOWNTIME_REASON = 'Rename table drepo_snapshots to drepo_project_snapshots'

  def up
    remove_index :drepo_snapshots, column: [:target_id, :target_type]
    rename_column :drepo_snapshots, :target_id, :project_id
    remove_column :drepo_snapshots, :target_type
    rename_column :drepo_snapshot_uploads, :snapshot_id, :project_snapshot_id
    add_index :drepo_snapshots, :project_id
    rename_table :drepo_snapshots, :drepo_project_snapshots
    rename_table :drepo_snapshot_uploads, :drepo_project_snapshot_uploads
  end

  def down
    rename_table :drepo_project_snapshots, :drepo_snapshots
    rename_table :drepo_project_snapshot_uploads, :drepo_snapshot_uploads
    remove_index :drepo_snapshots, :project_id
    rename_column :drepo_snapshot_uploads, :project_snapshot_id, :snapshot_id
    # add_column :drepo_snapshots, :target_type, :string
    rename_column :drepo_snapshots, :project_id, :target_id
    add_index :drepo_snapshots, [:target_id, :target_type]
  end
end
