# frozen_string_literal: true

class AddBranchNamesAndTagNamesToDrepoSnapshots < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :drepo_snapshots, :reason, :string

    add_column :drepo_snapshots, :branches, :jsonb
    add_column :drepo_snapshots, :tags, :jsonb

    Snapshot.find_each do |s|
      s.build_branches
      s.build_tags
      s.save
    end
  end
end
