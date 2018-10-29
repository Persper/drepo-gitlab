module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a Docker Registry credential for Kaniko.
        #
        class KanikoCredential < Node
          include Validatable
          include Attributable

          DEFAULT_REGISTRY = '$CI_REGISTRY'.freeze
          DEFAULT_USERNAME = '$CI_REGISTRY_USER'.freeze
          DEFAULT_PASSWORD = '$CI_REGISTRY_PASSWORD'.freeze
          ALLOWED_KEYS = %i[registry username password].freeze

          attributes ALLOWED_KEYS

          validations do
            validates :config, type: Hash
            validates :config, allowed_keys: ALLOWED_KEYS

            validates :registry, type: String, presence: true
            validates :username, type: String, presence: true
            validates :password, type: String, presence: true
          end

          def self.default
            { registry: DEFAULT_REGISTRY,
              username: DEFAULT_USERNAME,
              password: DEFAULT_PASSWORD }
          end
        end
      end
    end
  end
end
