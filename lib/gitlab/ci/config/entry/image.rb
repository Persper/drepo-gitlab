module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a Docker image.
        #
        class Image < Node
          include Validatable
          include Attributable

          ALLOWED_KEYS = %i[name entrypoint user].freeze

          attributes ALLOWED_KEYS

          validations do
            validates :config, hash_or_string: true
            validates :config, allowed_keys: ALLOWED_KEYS

            validates :name, type: String, presence: true

            with_options allow_nil: true do
              validates :entrypoint, array_of_strings: true
              validates :user, type: String
            end
          end

          def hash?
            @config.is_a?(Hash)
          end

          def string?
            @config.is_a?(String)
          end

          def value
            return { name: @config } if string?
            return @config if hash?

            {}
          end
        end
      end
    end
  end
end
