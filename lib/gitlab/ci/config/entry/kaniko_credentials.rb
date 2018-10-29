module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents Docker Registry credentials for Kaniko.
        #
        class KanikoCredentials < Node
          include Validatable

          validations do
            validates :config, type: Array
          end

          def self.default
            [ Entry::KanikoCredential.default ]
          end

          def compose!(deps = nil)
            super do
              @entries = []
              @config.each do |config|
                @entries << Entry::Factory.new(Entry::KanikoCredential)
                                .value(config)
                                .create!
              end

              # Ensure, that default credentials for internal registry are
              # always added to the configuration
              @entries << Entry::Factory.new(Entry::KanikoCredential)
                              .value(Entry::KanikoCredential.default)
                              .create!

              @entries.each do |entry|
                entry.compose!(deps)
              end
            end
          end

          def value
            config = { auth: {} }
            @entries.each do |credential|
              config[:auth][credential.registry] = { username: credential.username,
                                                     password: credential.password }
            end

            %Q(echo "#{config.to_json.gsub('"', '\"')}" > /kaniko/.docker/config.json)
          end

          def descendants
            @entries
          end
        end
      end
    end
  end
end
