# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndexToNamespacesRunnersToken < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :namespaces, :runners_token, unique: true
  end

  def down
    if index_exists?(:namespaces, :runners_token, unique: true)
      # rubocop:disable Migration/RemoveIndex
      remove_index :namespaces, :runners_token
    end
  end
end
