# frozen_string_literal: true

class CreateDrepoGroupSnapshots < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  def change
    create_table :drepo_group_snapshots do |t|
      t.integer :author_id
      t.jsonb :content
      t.string :ipfs_path
      t.string :state
      t.text :reason
      t.integer :group_id
      t.integer :group_path
      t.integer :parent_id
      t.datetime_with_timezone :state_updated_at

      t.timestamps_with_timezone null: false

      t.index :author_id
      t.index :group_id
      t.index :parent_id
    end
  end
end
