class CreateMergeRequestPipelinesTable < ActiveRecord::Migration
  DOWNTIME = false

  def change
    create_table :merge_request_pipelines, id: :bigserial do |t|
      t.references :merge_request, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.references :pipeline, null: false, index: true
      t.foreign_key :ci_pipelines, column: :pipeline_id, on_delete: :cascade

      t.datetime_with_timezone :created_at, null: false
    end
  end
end
