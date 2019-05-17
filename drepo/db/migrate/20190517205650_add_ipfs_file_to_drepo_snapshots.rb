# frozen_string_literal: true

class AddIpfsFileToDrepoSnapshots < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column :drepo_snapshots, :ipfs_file, :jsonb
  end
end
