# frozen_string_literal: true

module Ci
  class DeploymentSuccessWorker
    include ApplicationWorker
    include PipelineQueue

    queue_namespace :pipeline_processing

    def perform(deployment_id)
      Deployment.find_by_id(deployment_id).try do |deployment|
        UpdateDeploymentService.new(deployment).execute
      end
    end
  end
end
