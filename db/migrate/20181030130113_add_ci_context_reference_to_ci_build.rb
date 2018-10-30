# frozen_string_literal: true

class AddCiContextReferenceToCiBuild < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_reference :ci_builds, :context, index: true
  end
end
