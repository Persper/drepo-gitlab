# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a configuration of Docker services.
        #
        class Services < Node
          include Validatable

          validations do
            validates :config, type: Array
          end

          def compose!(deps = nil)
            super do
              @entries = []
              @config.each do |config|
                @entries << Entry::Factory.new(Entry::Service)
                  .value(config || {})
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
