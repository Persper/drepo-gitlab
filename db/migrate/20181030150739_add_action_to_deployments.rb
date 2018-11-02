# frozen_string_literal: true

class AddActionToDeployments < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    add_column :deployments, :action, :integer, limit: 2
  end

  def down
    remove_column :deployments, :action, :integer, limit: 2
  end
end
