# frozen_string_literal: true

class BuildSuccessWorker
  include ApplicationWorker
  include PipelineQueue

  queue_namespace :pipeline_processing

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(build_id)
    # no-op
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
