# frozen_string_literal: true

module Drepo
  module ImportExport
    class UploadsSaver
      def initialize(project:, shared:)
        @project = project
        @shared = shared
      end

      def save
        Drepo::ImportExport::UploadsManager.new(
          project: @project,
          shared: @shared
        ).save
      rescue => e
        @shared.error(e)
        false
      end
    end
  end
end
