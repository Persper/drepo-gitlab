# frozen_string_literal: true

class AddCiWorkspaceReferenceToCiBuild < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_reference :ci_builds, :workspace, index: true
  end
end
