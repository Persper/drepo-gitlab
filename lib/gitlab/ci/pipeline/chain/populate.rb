# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        class Populate < Chain::Base
          include Chain::Helpers

          PopulateError = Class.new(StandardError)

          def perform!
            # Allocate next IID. This operation must be outside of transactions of pipeline creations.
            pipeline.ensure_project_iid!

            ##
            # Populate pipeline with block argument of CreatePipelineService#execute.
            #
            @command.seeds_block&.call(pipeline)

            ##
            # Populate pipeline with all stages, and stages with builds.
            #
            pipeline.stage_seeds.each do |stage|
              pipeline.stages << stage.to_resource
            end

            if pipeline.stages.none?
              return error('No stages / jobs for this pipeline.')
            end

            if pipeline.invalid?
              return error('Failed to build the pipeline!')
            end

            raise Populate::PopulateError if pipeline.persisted?
          end

          def break?
            pipeline.errors.any?
          end
        end
      end
    end
  end
end
