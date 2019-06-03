# frozen_string_literal: true

module Gitlab
  module DrepoImportExport
    class ProjectTreeSaver
      include Gitlab::DrepoImportExport::CommandLineUtil

      attr_reader :full_path

      def initialize(project:, current_user:, shared:, params: {})
        @params = HashWithIndifferentAccess.new(params)
        @current_user = current_user
        @shared = shared
        @full_path = File.join(@shared.export_path, DrepoImportExport.project_filename)
        @snapshot = ::Dg::ProjectSnapshot.find_by(id: @params[:project_snapshot_id])

        # reload project from drepo_project_pending schema
        Apartment::Tenant.switch(Snapshots::BaseSnapshot::DREPO_PROJECT_PENDING) do
          @project = Project.find project.id
        end
      end

      def save
        mkdir_p(@shared.export_path)

        File.write(full_path, project_json_tree)
        true
      rescue => e
        @shared.error(e)
        false
      end

      private

      def project_json_tree
        # export porject tree from drepo_project_pending schema
        Apartment::Tenant.switch(Snapshots::BaseSnapshot::DREPO_PROJECT_PENDING) do
          if @params[:description].present?
            project_json['description'] = @params[:description]
          end

          if @params[:export_format] == :fingerprint
            project_json['project_members'].merge!(group_members_json.map { |g| [g['id'], g] }.to_h)
          else
            project_json['project_members'] += group_members_json
          end
        end

        project_json['related_users'] = @snapshot.related_users if @snapshot

        RelationRenameService.add_new_associations(project_json)

        project_json.to_json
      end

      def project_json
        @project_json ||=
          if @params[:export_format] == :fingerprint
            Gitlab::DrepoImportExport::Serialization.new.as_json(
              @project,
              @project.model_name.element,
              reader.project_tree
            )
          else
            @project.as_json(reader.project_tree)
          end
      end

      def reader
        @reader ||= Reader.new(shared: @shared)
      end

      def group_members_json
        group_members.as_json(reader.group_members_tree).each do |group_member|
          group_member['source_type'] = 'Project' # Make group members project members of the future import
        end
      end

      def group_members
        return [] unless @current_user.can?(:admin_group, @project.group)

        # We need `.where.not(user_id: nil)` here otherwise when a group has an
        # invitee, it would make the following query return 0 rows since a NULL
        # user_id would be present in the subquery
        # See http://stackoverflow.com/questions/129077/not-in-clause-and-null-values
        non_null_user_ids = @project.project_members.where.not(user_id: nil).select(:user_id)

        GroupMembersFinder.new(@project.group).execute.where.not(user_id: non_null_user_ids)
      end
    end
  end
end
