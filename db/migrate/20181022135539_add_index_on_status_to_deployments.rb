# frozen_string_literal: true

class AddIndexOnStatusToDeployments < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :deployments, :status
  end

  def down
    remove_concurrent_index :deployments, :status
  end
end
