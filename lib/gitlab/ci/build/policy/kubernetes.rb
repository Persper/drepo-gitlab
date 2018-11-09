# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Policy
        class Kubernetes < Policy::Specification
          def initialize(spec)
            unless spec.to_sym == :active
              raise UnknownPolicyError
            end
          end

          def satisfied_by?(pipeline, seed = nil)
            build = seed.to_resource
            build.project.deployment_platform(environment: build.environment)&.active?
          end
        end
      end
    end
  end
end
