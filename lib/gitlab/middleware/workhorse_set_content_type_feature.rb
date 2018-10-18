# frozen_string_literal: true

# This middleware sets a header in the response if the feature
# workhorse_set_content_type is enabled. This way we can enable/disable
# the feature in Workhorse.
# This feature let Workhorse set the proper Content-Type and Content-Disposition
# headers, because it is the component that really process the files and
# blobs contents.
# The Content-Type can still be forced from Rails if the header
# Allow-Content-Type is set.
# https://dev.gitlab.org/gitlab/gitlab-workhorse/merge_requests/3

module Gitlab
  module Middleware
    class WorkhorseSetContentTypeFeature
      FEATURE_HEADER = 'Gitlab-Workhorse-Set-Content-Type'.freeze

      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)

        if Feature.enabled?(:workhorse_set_content_type) && workhorse_send_request?(headers)
          headers[FEATURE_HEADER] = "true"
        end

        [status, headers, body]
      end

      private

      def workhorse_send_request?(headers)
        (headers.keys & [Gitlab::Workhorse::SEND_DATA_HEADER, 'X-Sendfile']).any?
      end
    end
  end
end
