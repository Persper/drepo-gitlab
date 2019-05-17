# frozen_string_literal: true

module Gitlab
  module DrepoImportExport
    module AfterExportStrategies
      class DownloadNotificationStrategy < BaseAfterExportStrategy
        private

        def strategy_execute
          notification_service.project_exported(project, current_user)
        end

        def notification_service
          @notification_service ||= NotificationService.new
        end
      end
    end
  end
end
