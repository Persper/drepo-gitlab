# frozen_string_literal: true

class AddFinishedAtToDeployments < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DEPLOYMENT_STATUS_SUCCESS = 2 # Equavalant to Deployment.state_machine.states['success'].value

  DOWNTIME = false

  def up
    add_column :deployments, :finished_at, :datetime_with_timezone
    add_column :deployments, :action, :integer, limit: 2
  end

  def down
    remove_column :deployments, :finished_at, :datetime_with_timezone
    remove_column :deployments, :action, :integer, limit: 2
  end
end
