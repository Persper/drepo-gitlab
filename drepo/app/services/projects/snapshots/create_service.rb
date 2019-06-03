# frozen_string_literal: true

module Projects
  module Snapshots
    class CreateService < BaseService
      CreateError = Class.new(StandardError)

      def initialize(user, params)
        @current_user, @params = user, params.dup
      end

      def execute
        # rubocop: disable CodeReuse/ActiveRecord

        unless Dg::ProjectSnapshot.where(params.merge(state: Dg::ProjectSnapshot::UNCOMPLETED_STATES.values)).empty?
          raise CreateError, "You must finish or cancel the uncompleted snapshots."
        end

        # rubocop: enable CodeReuse/ActiveRecord

        # need snapshot.id, so here must be #create
        @snapshot = Dg::ProjectSnapshot.create(params.merge(author: current_user))

        create_project_snapshot

        @snapshot
      end

      def create_project_snapshot
        # Here will set snapshot.related_users, but not save
        ::Snapshots::ProjectSnapshot.new(snapshot: @snapshot, root_id: @snapshot.project_id).create
        @snapshot.build_branches
        @snapshot.build_tags
        # must be execute after creating project snapshot in drepo_project_pending schema
        # will read snapshot.related_users
        @snapshot.snap!
        # export to a tar fild and upload to ipfs, it is a sidekiq job
        @snapshot.project.add_drepo_export_job(current_user: current_user, params: { project_snapshot_id: @snapshot.id })
      rescue StandardError => e
        @snapshot.reason = e.message
        @snapshot.crash!
      end
    end
  end
end
