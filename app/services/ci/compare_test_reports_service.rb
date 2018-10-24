# frozen_string_literal: true

module Ci
  class CompareTestReportsService < ::BaseService
    TimeoutError = Class.new(StandardError)

    SLEEP_SEC = 1.second
    TIME_OUT = 5.minutes

    def execute(base_pipeline, head_pipeline)
      # rubocop: disable CodeReuse/Serializer
      wait_for_parsed_results(base_pipeline, head_pipeline) do |base_test_reports, head_test_reports|
        comparer = Gitlab::Ci::Reports::TestReportsComparer
          .new(base_test_reports, head_test_reports)

        {
          status: :parsed,
          key: key(base_pipeline, head_pipeline),
          data: TestReportsComparerSerializer
            .new(project: project)
            .represent(comparer).as_json
        }
      end
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

    def wait_for_parsed_results(base_pipeline, head_pipeline)
      start_time = Time.now

      loop do
        t1 = base_pipeline&.test_reports
        t2 = head_pipeline.test_reports

        if (!base_pipeline && t2) || (t1 && t2)
          return yield t1, t2
        end

        if (Time.now - start_time) > TIME_OUT
          raise TimeoutError, "Parsing test reports timed out"
        end

        sleep(SLEEP_SEC)
      end
    end
  end
end
