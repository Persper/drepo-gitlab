# frozen_string_literal: true

class PoolRepository < BaseRepository
  POOL_PREFIX = '@pools'

  has_many :pool_member_projects, class_name: 'Project', foreign_key: :pool_repository_id
end
