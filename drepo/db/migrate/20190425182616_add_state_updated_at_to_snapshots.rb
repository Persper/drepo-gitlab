# frozen_string_literal: true

class AddStateUpdatedAtToSnapshots < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :drepo_snapshots, :state_updated_at, :datetime_with_timezone
    add_column :drepo_snapshots, :creator_id, :integer

    add_concurrent_index :drepo_snapshots, :creator_id
  end

  def down
    remove_column :drepo_snapshots, :state_updated_at, :datetime_with_timezone
    remove_column :drepo_snapshots, :creator_id, :integer

    remove_concurrent_index :drepo_snapshots, :create_id
  end
end
