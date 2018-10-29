module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a configuration of Docker image builds for Kaniko.
        #
        class KanikoImages < Node
          include Validatable

          validations do
            validates :config, type: Array
          end

          def self.default
            [ Entry::KanikoImage.default ]
          end

          def compose!(deps = nil)
            super do
              @entries = []
              @config.each do |config|
                @entries << Entry::Factory.new(Entry::KanikoImage)
                                .value(config)
                                .create!
              end

              @entries.each do |entry|
                entry.compose!(deps)
              end
            end
          end

          def value
            @entries.map(&:value)
          end

          def descendants
            @entries
          end
        end
      end
    end
  end
end
