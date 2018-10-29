# frozen_string_literal: true

class AddStatusToDeployments < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DEPLOYMENT_STATUS_SUCCESS = 2 # Equivalent to Deployment.state_machine.states['success'].value

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column_with_default(:deployments,
      :status,
      :integer,
      limit: 2,
      default: DEPLOYMENT_STATUS_SUCCESS,
      allow_null: false)
  end

  def down
    remove_column(:deployments, :status)
  end
end
