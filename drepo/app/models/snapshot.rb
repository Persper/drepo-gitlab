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

  belongs_to :target, polymorphic: true, inverse_of: :snapshot
  belongs_to :author, class_name: 'User'
end
