# frozen_string_literal: true

class BuildFinishedWorker
  include ApplicationWorker
  include PipelineQueue

  queue_namespace :pipeline_processing

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(build_id)
    Ci::Build.find_by(id: build_id).try do |build|
      # We execute that in sync as this access the files in order to access local file, and reduce IO
      BuildTraceSectionsWorker.new.perform(build.id)
      BuildCoverageWorker.new.perform(build.id)

      # We execute that async as this are two independent operations that can be executed after TraceSections and Coverage
      BuildHooksWorker.perform_async(build.id)
      ArchiveTraceWorker.perform_async(build.id)
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
