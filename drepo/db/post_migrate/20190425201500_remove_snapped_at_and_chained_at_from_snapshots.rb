# frozen_string_literal: true

class RemoveSnappedAtAndChainedAtFromSnapshots < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  def change
    remove_column :drepo_snapshots, :snapped_at, :datetime_with_timezone
    remove_column :drepo_snapshots, :snapped_by_id, :integer
    remove_column :drepo_snapshots, :chained_at, :datetime_with_timezone
    remove_column :drepo_snapshots, :chained_by_id, :integer
  end
end
