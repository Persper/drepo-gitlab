class AddTmpPartialNullIndexToBuilds < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    add_concurrent_index(:ci_builds, :id, where: 'stage_id IS NULL',
                                          name: 'tmp_id_partial_null_index')
  end

  def down
    remove_concurrent_index_by_name(:ci_builds, 'tmp_id_partial_null_index')
  end
end
