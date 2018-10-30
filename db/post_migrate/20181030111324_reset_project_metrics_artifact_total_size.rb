# frozen_string_literal: true

class ResetProjectMetricsArtifactTotalSize < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    ActiveRecord::Base.connection.execute <<~SQL
      UPDATE project_statistics
      SET build_artifacts_size=(
        SELECT SUM(size)
        FROM ci_job_artifacts
        WHERE ci_job_artifacts.project_id = project_statistics.project_id
      )
    SQL
  end

  def down
    # no-op
  end
end
