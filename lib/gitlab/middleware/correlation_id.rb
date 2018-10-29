# A dumb middleware that returns a Go HTML document if the go-get=1 query string
# is used irrespective if the namespace/project exists
module Gitlab
  module Middleware
    class CorrelationId
      include ActionView::Helpers::TagHelper

      CORRELATION_HEADER = 'HTTP_CORRELATION_ID'

      def initialize(app)
        @app = app
      end

      def call(env)
        Gitlab::JsonLogger.use_correlation_id(correlation_id) do
          @app.call(env)
        end
      end

      private

      def correlation_id
        env[CORRELATION_HEADER] || SecureRandom.hex
      end
    end
  end
end
