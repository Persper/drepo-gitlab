# frozen_string_literal: true

class AddIndexOnActionToDeployments < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :deployments, [:environment_id, :action]
    add_concurrent_index :deployments, [:project_id, :action]
  end

  def down
    remove_concurrent_index :deployments, [:environment_id, :action]
    remove_concurrent_index :deployments, [:project_id, :action]
  end
end
