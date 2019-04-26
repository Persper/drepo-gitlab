# frozen_string_literal: true

module Drepo
  module Project
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      has_many :snapshots, as: :target, dependent: :destroy
    end

    def create_snapshot(current_user)
      params = {
        target_id: self.id,
        target_type: self.class.name
      }
      Snapshots::CreateService.new(current_user, params).execute
    end

    def cancel_snapshot(current_user)
      params = {
        target_id: self.id,
        target_type: self.class.name
      }
      Snapshots::CancelService.new(current_user, params).execute
    end

    def drepo_import_export_shared
      @drepo_import_export_shared ||= ::Gitlab::DrepoImportExport::Shared.new(self)
    end

    def add_drepo_export_job(current_user:, after_export_strategy: nil, params: {})
      job_id = DrepoProjectExportWorker.perform_async(current_user.id, self.id, after_export_strategy, params)

      if job_id
        Rails.logger.info "Drepo Export job started for project ID #{self.id} with job ID #{job_id}"
      else
        Rails.logger.error "Drepo Export job failed to start for project ID #{self.id}"
      end
    end

    override :add_import_job
    def add_import_job
      if !drepo_import?
        super
      else
        job_id = DrepoRepositoryImportWorker.set(retry: false).perform_async(self.id)
        log_import_activity(job_id)
        job_id
      end
    end

    def drepo_import?
      import_type == 'drepo'
    end

    override :import?
    def import?
      super || drepo_import?
    end

    def current_snapshot
      snapshots.last
    end
  end
end
