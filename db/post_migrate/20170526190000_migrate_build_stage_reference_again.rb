# rubocop:disable Migration/UpdateLargeTable
class MigrateBuildStageReferenceAgain < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    stage_id = Arel.sql <<-SQL.strip_heredoc
      (SELECT id FROM ci_stages
         WHERE ci_stages.pipeline_id = ci_builds.commit_id
           AND ci_stages.name = ci_builds.stage)
    SQL

    disable_statement_timeout do
      update_column_in_batches(:ci_builds, :stage_id, stage_id) do |table, query|
        query.where(table[:stage_id].eq(nil))
      end
    end
  end

  def down
    disable_statement_timeout do
      update_column_in_batches(:ci_builds, :stage_id, nil)
    end
  end
end
