module Gitlab
  module Ci
    module Pipeline
      module Chain
        class Create < Chain::Base
          include Chain::Helpers

          # rubocop: disable CodeReuse/ActiveRecord
          def perform!
            pipeline.save!
          rescue ActiveRecord::RecordInvalid => e
            error("Failed to persist the pipeline: #{e}")
          end
          # rubocop: enable CodeReuse/ActiveRecord

          def break?
            !pipeline.persisted?
          end
        end
      end
    end
  end
end
