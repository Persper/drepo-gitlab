# frozen_string_literal: true

module Deployable
  extend ActiveSupport::Concern

  included do
    has_many :real_deployments, as: :deployable, class_name: 'Deployment'

    after_create :create_deployment

    def create_deployment
      return unless has_environment?

      environment = project.environments.find_or_create_by(
        name: expanded_environment_name
      )

      environment.deployments.create!(
        project_id: environment.project_id,
        environment: environment,
        ref: self.ref,
        tag: self.tag,
        sha: self.sha,
        user: self.user,
        deployable: self,
        on_stop: on_stop)
    end

    def has_environment?
      raise NotImplementedError
    end

    def expanded_environment_name
      raise NotImplementedError
    end

    def on_stop
      raise NotImplementedError
    end

    def update_deployments_status(event)
      real_deployments.each do |deployment|
        deployment.public_send(event) # rubocop:disable GitlabSecurity/PublicSend
      end
    end
  end
end
