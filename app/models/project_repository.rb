# frozen_string_literal: true

class ProjectRepository < BaseRepository
  has_one :project, foreign_key: :repository_id
end
