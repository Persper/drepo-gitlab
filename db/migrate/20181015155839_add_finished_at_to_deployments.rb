# frozen_string_literal: true

class AddFinishedAtToDeployments < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DEPLOYMENT_STATUS_SUCCESS = 2 # Equavalant to Deployment.state_machine.states['success'].value

  DOWNTIME = false

  class Deployment < ActiveRecord::Base
    self.table_name = 'deployments'
  end

  def up
    add_column :deployments, :finished_at, :datetime_with_timezone

    AddFinishedAtToDeployments::Deployment.find_in_batches(batch_size: 10_000) do |batch|
      batch.update_all('finished_at=created_at')
    end
  end

  def down
    remove_column :deployments, :finished_at, :datetime_with_timezone
  end
end
