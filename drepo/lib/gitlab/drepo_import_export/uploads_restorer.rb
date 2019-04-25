# frozen_string_literal: true

module Gitlab
  module DrepoImportExport
    class UploadsRestorer < UploadsSaver
      def restore
        Gitlab::DrepoImportExport::UploadsManager.new(
          project: @project,
          shared: @shared
        ).restore
      rescue => e
        @shared.error(e)
        false
      end
    end
  end
end
