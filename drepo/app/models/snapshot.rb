# frozen_string_literal: true

class Snapshot < ActiveRecord::Base
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
  ].freeze

  belongs_to :target, polymorphic: true, inverse_of: :snapshot
  belongs_to :snapped_by, class_name: 'User'
  belongs_to :chained_by, class_name: 'User'
end
