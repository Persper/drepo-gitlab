class AddIndexToCiJobArtifactsFileStore < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :ci_job_artifacts, :file_store
  end

  def down
    # rubocop:disable Migration/RemoveIndex
    remove_index :ci_job_artifacts, :file_store if index_exists?(:ci_job_artifacts, :file_store)
  end
end
