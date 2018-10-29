module Gitlab
  module SidekiqMiddleware
    class CorrelationLogger
      def call(worker, job, queue)
        Gitlab::JsonLogger.use_correlation_id("sidekiq:#{job['jid']}") do
          yield
        end
      end
    end
  end
end
