# frozen_string_literal: true

class RemoveRepoRefsFromDrepoSnapshots < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  def up
    remove_column :drepo_snapshots, :repo_refs, :jsonb
  end

  def down
    add_column :drepo_snapshots, :repo_refs, :jsonb

    Dg::Snapshot.find_each do |s|
      if s.project_snapshot?
        s.repo_refs = s.target.repository.ref_names
        s.save
      end
    end
  end
end
