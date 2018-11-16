class CleanupMergeRequestsAllowMaintainerToPushRename < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    # NOOP
  end

  def down
    if column_exists?(:merge_requests, :allow_collaboration)
      # rubocop:disable Migration/UpdateLargeTable
      rename_column_concurrently :merge_requests, :allow_collaboration, :allow_maintainer_to_push
    end
  end
end
