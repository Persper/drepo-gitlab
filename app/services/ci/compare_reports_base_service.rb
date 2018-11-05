# frozen_string_literal: true

module Ci
  class CompareReportsBaseService < ::BaseService

    def comparer_class
      raise NotImplementedError
    end

    def serializer_class
      raise NotImplementedError
    end

    def get_report(pipeline)
      raise NotImplementedError
    end

    def execute(base_pipeline, head_pipeline)
      # rubocop: disable CodeReuse/Serializer
      comparer = comparer_class.new(get_report(base_pipeline), get_report(head_pipeline))
      {
        status: :parsed,
        key: key(base_pipeline, head_pipeline),
        data: serializer_class
          .new(project: project)
          .represent(comparer).as_json
      }
    rescue => e
      {
        status: :error,
        key: key(base_pipeline, head_pipeline),
        status_reason: e.message
      }
      # rubocop: enable CodeReuse/Serializer
    end

    def latest?(base_pipeline, head_pipeline, data)
      data&.fetch(:key, nil) == key(base_pipeline, head_pipeline)
    end

    private

    def key(base_pipeline, head_pipeline)
      [
        base_pipeline&.id, base_pipeline&.updated_at,
        head_pipeline&.id, head_pipeline&.updated_at
      ]
    end
  end
end
