# frozen_string_literal: true

class AddFinishedAtToDeployments < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DEPLOYMENT_STATUS_SUCCESS = 2 # Equavalant to Deployment.state_machine.states['success'].value

  DOWNTIME = false

  def up
    add_column :deployments, :finished_at, :datetime_with_timezone
  end

  def down
    remove_column :deployments, :finished_at, :datetime_with_timezone
  end
end
