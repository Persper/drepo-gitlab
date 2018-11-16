class AddRetriedToCiBuild < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column(:ci_builds, :retried, :boolean)
  end
end
