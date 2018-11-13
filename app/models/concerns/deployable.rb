# frozen_string_literal: true

module Deployable
  extend ActiveSupport::Concern

  included do
    before_create :build_deployment

    def build_deployment
      return unless starts_environment? && !has_deployment?

      self.deployment = build_deployment(
        project_id: environment.project_id,
        environment: ensure_environment,
        ref: ref,
        tag: tag,
        sha: sha,
        user: user,
        on_stop: on_stop)
    end

    def ensure_environment
      project.environments.find_by_name(expanded_environment_name) || build_environment
    end

    def build_environment
      project.environments.build(name: expanded_environment_name)
    end
  end
end
