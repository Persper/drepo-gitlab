# frozen_string_literal: true

class AddBranchNamesAndTagNamesToDrepoSnapshots < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  def change
    add_column :drepo_snapshots, :reason, :string

    add_column :drepo_snapshots, :branches, :jsonb
    add_column :drepo_snapshots, :tags, :jsonb

    Dg::Snapshot.find_each do |s|
      s.build_branches if s.respond_to?(:build_branches) && s.respond_to?(:branches)
      s.build_tags if s.respond_to?(:build_tags) && s.respond_to?(:tags)
      s.save
    end
  end
end
