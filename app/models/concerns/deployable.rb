# frozen_string_literal: true

module Deployable
  extend ActiveSupport::Concern

  included do
    after_create :create_deployment

    def create_deployment
      return unless has_environment?

      environment = project.environments.find_or_create_by(
        name: expanded_environment_name
      )

      environment.deployments.create!(
        project_id: environment.project_id,
        environment: environment,
        ref: ref,
        tag: tag,
        sha: sha,
        user: user,
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

    def ref
      raise NotImplementedError
    end

    def tag
      raise NotImplementedError
    end

    def sha
      raise NotImplementedError
    end

    def user
      raise NotImplementedError
    end

    def project
      raise NotImplementedError
    end
  end
end
