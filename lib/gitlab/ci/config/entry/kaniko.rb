module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a configuration of Kaniko-based Docker build.
        #
        class Kaniko < Node
          include Configurable
          include Validatable
          include Attributable

          KANIKO_IMAGE = 'gcr.io/kaniko-project/executor:debug'.freeze
          ALLOWED_KEYS = %i[credentials images].freeze

          attributes ALLOWED_KEYS

          entry :credentials, Entry::KanikoCredentials, description: 'Credentials for Kaniko based Docker image build'
          entry :images, Entry::KanikoImages, description: 'Definition of images to build'

          helpers :credentials, :images

          validations do
            validates :config, type: Hash
            validates :config, allowed_keys: ALLOWED_KEYS

            with_options allow_nil: true do
              validates :credentials, type: Array
              validates :images, type: Array
            end
          end

          def self.default
            { credentials: Entry::KanikoCredentials.default, images: Entry::KanikoImages.default }
          end

          def value
            { script: [[credentials_value], images_value].flatten,
              image: { name: KANIKO_IMAGE, entrypoint: [''] } }
          end
        end
      end
    end
  end
end
