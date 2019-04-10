# frozen_string_literal: true

class Snapshot < ApplicationRecord
  self.table_name = 'drepo_snapshots'

  TARGET_TYPES = HashWithIndifferentAccess.new(
    project: Project
  ).freeze

  STATES = HashWithIndifferentAccess.new(
    created: 'created',
    snapped: 'snapped',
    chained: 'chained',
    failed: 'failed',
    cancelled: 'cancelled'
  ).freeze

  EXCLUDE_TABLES = %w[
    ar_internal_metadata
    schema_migrations
    prometheus_metrics
    drepo_snapshots
    tags
    taggings
    ci_build_trace_chunks
    ci_build_trace_section_names
    ci_build_trace_sections
    ci_builds
    ci_builds_metadata
    ci_builds_runner_session
    ci_group_variables
    ci_job_artifacts
    ci_pipeline_chat_data
    ci_pipeline_schedule_variables
    ci_pipeline_schedules
    ci_pipeline_variables
    ci_pipelines
    ci_runner_namespaces
    ci_runner_projects
    ci_runners
    ci_stages
    ci_trigger_requests
    ci_triggers
    ci_variables
    cluster_groups
    cluster_platforms_kubernetes
    cluster_projects
    cluster_providers_gcp
    clusters
    clusters_applications_cert_managers
    clusters_applications_helm
    clusters_applications_ingress
    clusters_applications_jupyter
    clusters_applications_knative
    clusters_applications_prometheus
    clusters_applications_runners
    clusters_kubernetes_namespaces
    project_auto_devops
    project_ci_cd_settings
    oauth_access_grants
    oauth_access_tokens
    oauth_openid_requests
    oauth_applications
    fork_network_members
    fork_networks
    gpg_key_subkeys
    deploy_tokens
    pages_domains
    pool_repositories
    programming_languages
    repository_languages
    sent_notifications
    shards
    trending_projects
    user_callouts
    user_interacted_projects
    user_statuses
    user_synced_attributes_metadata
    abuse_reports
    appearances
    application_settings
    application_setting_terms
    audit_events
    board_group_recent_visits
    board_project_recent_visits
    broadcast_messages
    chat_names
    container_repositories
    conversational_development_index_metrics
    deployments
    environments
    feature_gates
    features
    forked_project_links
    import_export_uploads
    project_import_data
    project_mirror_data
    project_statistics
    repositories
    site_statistics
    spam_logs
    web_hook_logs
    web_hooks
  ].freeze

  belongs_to :target, polymorphic: true, inverse_of: :snapshot
  belongs_to :snapped_by, class_name: 'User'
  belongs_to :chained_by, class_name: 'User'
end
