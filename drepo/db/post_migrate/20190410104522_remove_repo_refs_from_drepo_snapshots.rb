# frozen_string_literal: true

class RemoveRepoRefsFromDrepoSnapshots < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    remove_column :drepo_snapshots, :repo_refs
  end

  def down
    add_column :drepo_snapshots, :repo_refs, :jsonb

    Snapshot.find_each do |s|
      if s.project_snapshot?
        s.repo_refs = s.target.repository.ref_names
        s.save
      end
    end
  end
end
