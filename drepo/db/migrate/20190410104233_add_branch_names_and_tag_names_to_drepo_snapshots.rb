# frozen_string_literal: true

class AddBranchNamesAndTagNamesToDrepoSnapshots < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  def change
    add_column :drepo_snapshots, :reason, :string

    add_column :drepo_snapshots, :branches, :jsonb
    add_column :drepo_snapshots, :tags, :jsonb
  end
end
