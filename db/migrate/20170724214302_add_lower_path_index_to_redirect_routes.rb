# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddLowerPathIndexToRedirectRoutes < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_on_redirect_routes_lower_path'

  disable_ddl_transaction!

  def up
    return unless Gitlab::Database.postgresql?

    execute "CREATE INDEX CONCURRENTLY #{INDEX_NAME} ON redirect_routes (LOWER(path));"
  end

  def down
    return unless Gitlab::Database.postgresql?

    # Why not use remove_concurrent_index_by_name?
    #
    # `index_exists?` doesn't work on this index. Perhaps this is related to the
    # fact that the index doesn't show up in the schema. And apparently it isn't
    # trivial to write a query that checks for an index. BUT there is a
    # convenient `IF EXISTS` parameter for `DROP INDEX`.
    if supports_drop_index_concurrently?
      disable_statement_timeout do
        execute "DROP INDEX CONCURRENTLY IF EXISTS #{INDEX_NAME};"
      end
    else
      execute "DROP INDEX IF EXISTS #{INDEX_NAME};"
    end
  end
end
