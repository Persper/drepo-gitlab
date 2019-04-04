# frozen_string_literal: true

module Snapshots
  class CreateService < BaseService
    def initialize(user, params)
      @current_user, @params = user, params.dup
    end

    def execute
      target_klass = params[:target_type].constantize
      return unless Snapshot::TARGET_TYPES.values.include? target_klass

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
        ps = Snapshots::ProjectSnapshot.new(drepo_id: @snapshot.id, root_id: @snapshot.target_id)
        ps.create
        project = Project.find(@snapshot.target_id)
        @snapshot.repo_refs = project.repository.ref_names
        @snapshot.state = Snapshot::STATES[:snapped]
        @snapshot.snapped_at = Time.now
      rescue StandardError => e
        puts "-----------> #{e.message}"
        @snapshot.state = Snapshot::STATES[:failed]
      end

      @snapshot.save
    end
  end
end
