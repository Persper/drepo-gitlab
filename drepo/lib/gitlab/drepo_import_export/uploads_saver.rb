# frozen_string_literal: true

module Gitlab
  module DrepoImportExport
    class UploadsSaver
      def initialize(project:, shared:)
        @project = project
        @shared = shared
      end

      def save
        Gitlab::DrepoImportExport::UploadsManager.new(
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
