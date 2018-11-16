# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndexOnCiBuildsUserId < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :ci_builds, :user_id
  end

  def down
    remove_concurrent_index :ci_builds, :user_id if index_exists?(:ci_builds, :user_id)
  end
end
