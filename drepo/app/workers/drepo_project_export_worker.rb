# frozen_string_literal: true

class DrepoProjectExportWorker
  include ApplicationWorker
  include ExceptionBacktrace

  sidekiq_options retry: 3

  def perform(current_user_id, project_id, after_export_strategy = {}, params = {})
    current_user = User.find(current_user_id)
    project = Project.find(project_id)
    after_export = build!(after_export_strategy)

    Projects::DrepoImportExport::ExportService.new(project, current_user, params).execute(after_export)
  end

  private

  def build!(after_export_strategy)
    strategy_klass = after_export_strategy&.delete('klass')

    Gitlab::DrepoImportExport::AfterExportStrategyBuilder.build!(strategy_klass, after_export_strategy)
  end
end
