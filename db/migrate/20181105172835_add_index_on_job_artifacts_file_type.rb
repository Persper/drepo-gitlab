# frozen_string_literal: true
class AddIndexOnJobArtifactsFileType < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :ci_job_artifacts, :file_type
  end

  def down
    remove_concurrent_index :ci_job_artifacts, :file_type
  end
end
