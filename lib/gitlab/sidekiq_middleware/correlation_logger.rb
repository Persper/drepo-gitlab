module Gitlab
  module SidekiqMiddleware
    class CorrelationLogger
      def call(worker, job, queue)
        Gitlab::CorrelationId.use_id(job["correlation_id"]) do
          yield
        end
      end
    end
  end
end
