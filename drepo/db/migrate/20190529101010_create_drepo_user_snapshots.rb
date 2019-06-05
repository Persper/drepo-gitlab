# frozen_string_literal: true

class CreateDrepoUserSnapshots < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  def change
    create_table :drepo_user_snapshots do |t|
      t.integer :user_id
      t.jsonb :content
      t.string :ipfs_path
      t.string :state
      t.text :reason
      t.datetime_with_timezone :state_updated_at

      t.timestamps_with_timezone null: false

      t.index :user_id
    end
  end
end
