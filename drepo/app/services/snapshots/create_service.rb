# frozen_string_literal: true

module Snapshots
  class CreateService < BaseService
    def initialize(user, params)
      @current_user, @params = user, params.dup
    end

    def execute
      target_klass = params[:target_type].constantize
      return unless Snapshot::TARGET_TYPES.value? target_klass

      # need snapshot.id, so here must be #create
      @snapshot = Snapshot.create(params.merge(snapped_by: current_user))

      case @snapshot.target_type
      when 'Project'
        create_project_snapshot
      else
        nil
      end

      @snapshot
    end

    def create_project_snapshot
      begin
        Snapshots::ProjectSnapshot.new(drepo_id: @snapshot.id, root_id: @snapshot.target_id).create
        @snapshot.build_branches
        @snapshot.build_tags
        @snapshot.state = Snapshot::STATES[:snapped]
        @snapshot.snapped_at = Time.now
      rescue StandardError => e
        @snapshot.state = Snapshot::STATES[:failed]
        @snapshot.reason = e.message
      end

      @snapshot.save
    end
  end
end
