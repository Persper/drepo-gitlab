# frozen_string_literal: true

module Snapshots
  class CreateService < BaseService
    CreateError = Class.new(StandardError)

    def initialize(user, params)
      @current_user, @params = user, params.dup
    end

    def execute
      target_klass = params[:target_type].constantize

      unless Snapshot::TARGET_TYPES.values.include? target_klass
        raise CreateError, "Snapshot target_type must be included in #{Snapshot::TARGET_TYPES.values}"
      end

      # rubocop: disable CodeReuse/ActiveRecord
      unless Snapshot.where(params.merge(state: Snapshot::UNCOMPLETED_STATES.values)).empty?
        raise CreateError, "You must finish or cancel the uncompleted snapshots."
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # need snapshot.id, so here must be #create
      @snapshot = Snapshot.create(params.merge(author: current_user))

      case @snapshot.target_type
      when 'Project'
        create_project_snapshot
      else
        nil
      end

      @snapshot
    end

    def create_project_snapshot
      # Here will set snapshot.related_users, but not save
      Snapshots::ProjectSnapshot.new(snapshot: @snapshot, root_id: @snapshot.target_id).create
      @snapshot.build_branches
      @snapshot.build_tags
      # must be execute after creating project snapshot in drepo_project_pending schema
      # will read snapshot.related_users
      Projects::DrepoImportExport::ExportService.new(@snapshot.target, @current_user, snapshot: @snapshot)
        .execute(Gitlab::DrepoImportExport::AfterExportStrategies::DownloadNotificationStrategy.new)
      @snapshot.snap!
    rescue StandardError => e
      @snapshot.reason = e.message
      @snapshot.crash!
    end
  end
end
