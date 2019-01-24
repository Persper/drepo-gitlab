# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddUuidToSomeTables < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  # When a migration requires downtime you **must** uncomment the following
  # constant and define a short and easy to understand explanation as to why the
  # migration requires downtime.
  # DOWNTIME_REASON = ''

  # When using the methods "add_concurrent_index", "remove_concurrent_index" or
  # "add_column_with_default" you must disable the use of transactions
  # as these methods can not run in an existing transaction.
  # When using "add_concurrent_index" or "remove_concurrent_index" methods make sure
  # that either of them is the _only_ method called in the migration,
  # any other changes should go in a separate migration.
  # This ensures that upon failure _only_ the index creation or removing fails
  # and can be retried or reverted easily.
  #
  # To disable transactions uncomment the following line and remove these
  # comments:
  disable_ddl_transaction!

  ## Postgres only, because used Postgres builtin function uuid_generate_v4()
  def up
    uuid_tables.each do |table|
      add_column_with_default(table, drepo_column, :uuid, default: "uuid_generate_v4()", allow_null: false) do |t, update_arel|
        update_arel.set([[t[drepo_column], Arel.sql('uuid_generate_v4()')]]) if Arel::UpdateManager === update_arel
        update_arel
      end
      add_concurrent_index table, drepo_column, unique: true
    end
  end

  def down
    uuid_tables.each do |table|
      remove_concurrent_index(table, drepo_column) if index_exists?(table, drepo_column, unique: true)
      remove_column(table, drepo_column) if column_exists?(table, drepo_column)
    end
  end

  def drepo_column
    :drepo_uuid
  end

  def uuid_tables
    # version: 1 && inline: false
    %w[
      badges
      boards
      emails
      events
      fork_network_members
      fork_networks
      group_custom_attributes
      internal_ids
      issue_metrics
      issues
      label_links
      label_priorities
      labels
      lfs_file_locks
      lfs_objects
      lfs_objects_projects
      lists
      members
      merge_request_diffs
      merge_request_metrics
      merge_requests
      merge_requests_closing_issues
      milestones
      namespaces
      note_diff_files
      notes
      notification_settings
      pages_domains
      personal_access_tokens
      project_custom_attributes
      project_deploy_tokens
      project_features
      project_group_links
      projects
      protected_branch_merge_access_levels
      protected_branch_push_access_levels
      protected_branches
      protected_tag_create_access_levels
      protected_tags
      redirect_routes
      releases
      remote_mirrors
      routes
      services
      snippets
      subscriptions
      term_agreements
      timelogs
      u2f_registrations
      user_custom_attributes
      user_preferences
      user_statuses
      user_synced_attributes_metadata
      users
      users_star_projects
      web_hooks
    ]
  end
end
