# rubocop:disable Migration/UpdateLargeTable
class AddHeadPipelineForEachMergeRequest < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    pipelines = Arel::Table.new(:ci_pipelines)
    merge_requests = Arel::Table.new(:merge_requests)

    disable_statement_timeout do
      head_id = pipelines
        .project(Arel::Nodes::NamedFunction.new('max', [pipelines[:id]]))
        .from(pipelines)
        .where(pipelines[:ref].eq(merge_requests[:source_branch]))
        .where(pipelines[:project_id].eq(merge_requests[:source_project_id]))

      sub_query = Arel::Nodes::SqlLiteral.new(Arel::Nodes::Grouping.new(head_id).to_sql)

      update_column_in_batches(:merge_requests, :head_pipeline_id, sub_query)
    end
  end

  def down
  end
end
