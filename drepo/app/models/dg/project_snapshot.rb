# frozen_string_literal: true

module Dg
  class ProjectSnapshot < ApplicationRecord
    extend Gitlab::Dg::Model

    STATES = HashWithIndifferentAccess.new(
      created: 'created',
      snapped: 'snapped',
      exported: 'exported',
      chained: 'chained',
      failed: 'failed',
      cancelled: 'cancelled'
    ).freeze

    UNCOMPLETED_STATES = HashWithIndifferentAccess.new(
      created: 'created',
      snapped: 'snapped',
      exported: 'exported'
    ).freeze

    # The resources belong to user, but managed by project
    USER_SHARED_TABLE_COLUMNS = HashWithIndifferentAccess.new(
      snippets: 'author_id',
      issues: 'author_id',
      notes: 'author_id',
      events: 'author_id',
      merge_requests: 'author_id',
      award_emoji: 'user_id',
      members: 'user_id'
    ).freeze

    ENHANCE_TABLES = %w[
      issue_assignees
      labels
      lists
      merge_request_assignees
      subscriptions
      suggestions
      term_agreements
      timelogs
      users
      user_custom_attributes
      user_preferences
      award_emoji
      deploy_keys_projects
      emails
      events
      gpg_keys
      identities
      keys
      lfs_file_locks
      merge_request_diffs
      merge_requests_closing_issues
      project_authorizations
      project_error_tracking_settings
      project_repositories
      protected_branch_push_access_levels
      redirect_routes
      routes
      system_note_metadata
      todos
      uploads
      users_star_projects
      badges
      boards
      gpg_signatures
      group_custom_attributes
      merge_request_diff_commits
      notification_settings
      merge_request_diff_files
      note_diff_files
      notes
      issue_metrics
      internal_ids
      issues
      label_links
      label_priorities
      lfs_objects
      lfs_objects_projects
      members
      merge_requests
      merge_request_metrics
      milestones
      namespaces
      personal_access_tokens
      project_custom_attributes
      project_daily_statistics
      project_deploy_tokens
      project_features
      project_group_links
      projects
      protected_branch_merge_access_levels
      protected_branches
      protected_tag_create_access_levels
      protected_tags
      push_event_payloads
      release_links
      releases
      remote_mirrors
      resource_label_events
      services
      snippets
      u2f_registrations
      user_agent_details
    ].freeze

    belongs_to :author, class_name: 'User'
    belongs_to :project, inverse_of: :snapshots
    has_one :project_snapshot_upload, dependent: :destroy

    state_machine :state, initial: :created do
      state :snapped
      state :exported
      state :chained
      state :failed
      state :cancelled

      event :snap do
        transition created: :snapped
      end

      event :export do
        transition snapped: :exported
      end

      event :crash do
        transition [:created, :snapped, :exported] => :failed
      end

      event :chain do
        transition exported: :chained
      end

      event :cancel do
        transition [:created, :snapped, :exported] => :cancelled
      end

      after_transition any => any do |snapshot|
        snapshot.state_updated_at = Time.now
      end
    end

    def build_branches
      branch_names = project.repository.branch_names

      self.branches = branch_names.each_with_object([]) do |name, object|
        branch = project.repository.find_branch name
        object << { name: name, sha: branch.dereferenced_target.id }
      rescue
        # just drop this branch
      end
    end

    def build_tags
      tag_names = project.repository.tag_names

      self.tags = tag_names.each_with_object([]) do |name, object|
        tag = project.repository.find_tag name
        object << { name: name, sha: tag.dereferenced_target.id }
      rescue
        # just drop this tag
      end
    end

    def remove_exports
      return unless export_file_exists?

      project_snapshot_upload.remove_export_file!
      project_snapshot_upload.save unless project_snapshot_upload.destroyed?
    end

    def export_file_exists?
      export_file&.file
    end

    def export_file
      project_snapshot_upload&.export_file
    end
  end
end
