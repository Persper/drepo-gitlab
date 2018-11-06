# A dumb middleware that steals correlation id
# and sets it as a global context for the request
module Gitlab
  module Middleware
    class CorrelationId
      include ActionView::Helpers::TagHelper

      HTTP_X_REQUEST_ID = 'HTTP_X_REQUEST_ID'

      def initialize(app)
        @app = app
      end

      def call(env)
        Gitlab::CorrelationId.use_id(correlation_id(env)) do
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
