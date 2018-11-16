# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class IndexRedirectRoutesPathForLike < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  INDEX_NAME = 'index_redirect_routes_on_path_text_pattern_ops'

  disable_ddl_transaction!

  def up
    return unless Gitlab::Database.postgresql?

    unless index_exists?(:redirect_routes, :path, name: INDEX_NAME)
      execute("CREATE INDEX CONCURRENTLY #{INDEX_NAME} ON redirect_routes (path varchar_pattern_ops);")
    end
  end

  def down
    return unless Gitlab::Database.postgresql?
    return unless index_exists?(:redirect_routes, :path, name: INDEX_NAME)

    remove_concurrent_index_by_name(:redirect_routes, INDEX_NAME)
  end
end
