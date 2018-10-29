module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a configuration of Docker image build for Kaniko.
        #
        class KanikoImage < Node
          include Validatable
          include Attributable

          DEFAULT_CONTEXT = '.'.freeze
          DEFAULT_DOCKERFILE = 'Dockerfile'.freeze
          DEFAULT_TAGS = ['$CI_REGISTRY_IMAGE'].freeze
          ALLOWED_KEYS = %i[args context dockerfile tags].freeze

          attributes :args

          def context
            @config[:context] || DEFAULT_CONTEXT
          end

          def dockerfile
            @config[:dockerfile] || DEFAULT_DOCKERFILE
          end

          def tags
            @config[:tags] || DEFAULT_TAGS
          end

          validations do
            validates :config, type: Hash
            validates :config, allowed_keys: ALLOWED_KEYS

            with_options allow_nil: true do
              validates :args, type: Hash
              validates :context, type: String
              validates :dockerfile, type: String
              validates :tags, array_of_strings: true
            end
          end

          def self.default
            { context: DEFAULT_CONTEXT,
              dockerfile: DEFAULT_DOCKERFILE,
              tags: DEFAULT_TAGS }
          end

          def value
            append_context
            append_dockerfile
            append_tags
            append_args

            command.join(' ')
          end

          private

          def command
            @command ||= ["/kaniko/executor"]
          end

          def append_context
            command << "--context $CI_PROJECT_DIR/#{context}"
          end

          def append_dockerfile
            command << "--dockerfile $CI_PROJECT_DIR/#{dockerfile}"
          end

          def append_args
            return unless args

            args.each do |arg, value|
              command << "--build-arg #{arg}=#{value}"
            end
          end

          def append_tags
            tags.each do |tag|
              command << "--destination #{tag}"
            end
          end
        end
      end
    end
  end
end
