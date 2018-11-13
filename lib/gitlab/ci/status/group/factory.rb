# frozen_string_literal: true

module Gitlab
  module Ci
    module Status
      module Group
        class Factory < Status::Factory
          def self.common_helpers
            Status::Group::Common
          end
        end
      end
    end
  end
end
