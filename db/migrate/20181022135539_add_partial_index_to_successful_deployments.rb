# frozen_string_literal: true

class AddPartialIndexToSuccessfulDeployments < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'partial_index_deployments_with_successful_deployments'.freeze

  disable_ddl_transaction!

  def up
    add_concurrent_index(:deployments, ['environment_id', 'id'], where: "status = 2 OR status IS NULL", name: INDEX_NAME)
  end

  def down
    remove_concurrent_index_by_name(:deployments, INDEX_NAME)
  end
end
