# frozen_string_literal: true

class AddSourceToCiBuild < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :ci_builds, :source, :integer
  end
end
