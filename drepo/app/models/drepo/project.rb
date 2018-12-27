# frozen_string_literal: true

module Drepo
  module Project
    def drepo_import_export_shared
      @drepo_import_export_shared ||= Drepo::ImportExport::Shared.new(self)
    end

    def add_drepo_export_job(current_user:, after_export_strategy: nil, params: {})
      job_id = Drepo::ProjectExportWorker.perform_async(current_user.id, self.id, after_export_strategy, params)

      if job_id
        Rails.logger.info "Drepo Export job started for project ID #{self.id} with job ID #{job_id}"
      else
        Rails.logger.error "Drepo Export job failed to start for project ID #{self.id}"
      end
    end
  end
end
