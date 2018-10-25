# frozen_string_literal: true

class BuildSuccessWorker
  include ApplicationWorker
  include PipelineQueue

  queue_namespace :pipeline_processing

  def perform(build_id)
    # no-op
  end
end
