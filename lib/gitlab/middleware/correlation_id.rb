# A dumb middleware that returns a Go HTML document if the go-get=1 query string
# is used irrespective if the namespace/project exists
module Gitlab
  module Middleware
    class CorrelationId
      include ActionView::Helpers::TagHelper

      HTTP_X_REQUEST_ID = 'HTTP_X_REQUEST_ID'

      def initialize(app)
        @app = app
      end

      def call(env)
        Gitlab::JsonLogger.use_correlation_id(correlation_id(env)) do
          @app.call(env)
        end
      end

      private

      def correlation_id(env)
        env[HTTP_X_REQUEST_ID] || SecureRandom.hex
      end
    end
  end
end
