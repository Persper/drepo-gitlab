# frozen_string_literal: true

module Deployable
  extend ActiveSupport::Concern

  included do
    after_create :create_deployment

    FailedToCreateEnvironmentError = Class.new(StandardError)

    def create_deployment
      return unless starts_environment? && !has_deployment?

      create_deployment!(
        project_id: project.id,
        environment: ensure_environment,
        ref: ref,
        tag: tag,
        sha: sha,
        user: user,
        on_stop: on_stop)
    end

    private

    def ensure_environment
      strong_memoize(:persisted_environment) do
        project.environments.find_by_name(expanded_environment_name) ||
          create_environment!
      end
    end

    # Environment name could have invalid character, such as `:` (colon).
    # If it's the case, we have to rollback parent's transaction, which is `pipeline.save!` or `build.save!`
    def create_environment!
      error_message = nil

      Environment.transaction(requires_new: true) do
        begin
          project.environments.create!(
            name: expanded_environment_name
          )
        rescue ActiveRecord::RecordInvalid => e
          error_message = e.message
          raise ActiveRecord::Rollback
        end
      end.tap do |ret|
        raise FailedToCreateEnvironmentError, error_message unless ret
      end
    end
  end
end
