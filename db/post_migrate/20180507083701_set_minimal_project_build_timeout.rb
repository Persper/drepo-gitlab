class SetMinimalProjectBuildTimeout < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  MINIMUM_TIMEOUT = 600

  # Allow this migration to resume if it fails partway through
  disable_ddl_transaction!

  def up
    # rubocop:disable Migration/UpdateLargeTable
    # rubocop:disable Migration/UpdateColumnInBatches
    update_column_in_batches(:projects, :build_timeout, MINIMUM_TIMEOUT) do |table, query|
      query.where(table[:build_timeout].lt(MINIMUM_TIMEOUT))
    end
  end

  def down
    # no-op
  end
end
