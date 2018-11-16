# frozen_string_literal: true

module Ci
  class CreateMergeRequestPipelinesService < BaseService
    def execute(source, **args, &block)
      return unless Feature.enabled?(:ci_merge_request_pipelines, default_enabled: true)

      find_merge_requests do |merge_request|
        Ci::CreatePipelineService
          .new(merge_request.target_project, current_user, params)
          .execute(source, args, merge_request: merge_request, &block)
      end
    end

    private

    def find_merge_requests(&block)
      MergeRequest.where(source_project: project, source_branch: params[:ref])
                  .opened
                  .find_each(&block)
    end
  end
end
