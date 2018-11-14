# frozen_string_literal: true

class AddProjectRepositoryToProjects < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  # disable_ddl_transaction!

  def change
    # rubocop:disable Migration/AddReference
    add_reference :projects, :repository,
                  index: { where: 'repository_id IS NOT NULL' },
                  foreign_key: true
    # rubocop:enable Migration/AddReference
  end
end
