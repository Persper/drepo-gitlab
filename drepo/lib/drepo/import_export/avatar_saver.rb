# frozen_string_literal: true

module Drepo
  module ImportExport
    class AvatarSaver
      def initialize(project:, shared:)
        @project = project
        @shared = shared
      end

      def save
        return true unless @project.avatar.exists?

        Drepo::ImportExport::UploadsManager.new(
          project: @project,
          shared: @shared,
          relative_export_path: 'avatar'
        ).save
      rescue => e
        @shared.error(e)
        false
      end
    end
  end
end
