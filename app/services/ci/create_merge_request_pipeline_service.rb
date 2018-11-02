# frozen_string_literal: true

module Ci
  class CreateMergeRequestPipelineService < BaseService
    attr_reader :source_branch, :source_project

    def execute(pipeline)
      return if pipeline.tag?
      return unless pipeline.has_merge_request_option?

      @source_branch = pipeline.ref
      @source_project = pipeline.project

      merge_requests.each do |merge_request|
        Ci::CreatePipelineService
          .new(merge_request.target_project,
               pipeline.user,
               ref: source_branch,
               merge_request: merge_request)
          .execute(pipeline.source)
      end
    end

    private

    def merge_requests
      @merge_requests ||= MergeRequest.where(source_project: source_project, source_branch: source_branch)
    end
  end
end
