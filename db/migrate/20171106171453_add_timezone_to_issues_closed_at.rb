# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddTimezoneToIssuesClosedAt < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    # rubocop:disable Migration/UpdateLargeTable
    change_column_type_concurrently(:issues, :closed_at, :datetime_with_timezone)
  end

  def down
    cleanup_concurrent_column_type_change(:issues, :closed_at)
  end
end
