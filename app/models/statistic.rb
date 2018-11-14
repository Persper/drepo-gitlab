# frozen_string_literal: true

class Statistic < ActiveRecord::Base
  belongs_to :project

  before_save :update_storage_size

  enum key: {
    commit_count: 0,
    repository_size: 1,
    lfs_objects_size: 2,
    job_artifacts_size: 3,
    repositories_count: 4
  }

  validates :key, presence: true

  def self.increment_project_statistic(project, key, amount)
    raise ArgumentError, "Cannot increment attribute: #{key}" unless keys.key?(key)
    return if amount == 0

    ActiveRecord::Base.transaction do
      project.statistic.public_send(key).increment(amount)
    end
  end

  def self.increment(amount)
    self.value ||= 0
    self.value += amount
    save
  end

  def storage_size
    query = <<~SQL
      SELECT sum(v) from
      (
        SELECT value AS v FROM statistics WHERE project_id = #{project.id} AND key = #{keys[:repository_size]} LIMIT 1
        union all
        SELECT value AS v FROM statistics WHERE project_id = #{project.id} AND key = #{keys[:lfs_objects_size]} LIMIT 1
        union all
        SELECT value AS v FROM statistics WHERE project_id = #{project.id} AND key = #{keys[:job_artifacts_size]} LIMIT 1
      )
    SQL

    ActiveRecord::Base.connection.select_all(query).first
  end
end
