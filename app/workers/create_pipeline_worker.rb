# frozen_string_literal: true

class CreatePipelineWorker
  include ApplicationWorker
  include PipelineQueue

  queue_namespace :pipeline_creation

  def perform(project_id, user_id, ref, source, params = {})
    project = Project.find(project_id)
    user = User.find(user_id)
    params = params.deep_symbolize_keys

    pipeline = Ci::CreatePipelineService
      .new(project, user, ref: ref)
      .execute(source, **params)

    # Create merge request pipelines
    Ci::CreateMergeRequestPipelinesService
      .new(project, user, ref: ref)
      .execute(source, **params)

    pipeline
  end
end
