# frozen_string_literal: true

class AddIndexToNamespaceTrialEndsOn < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :namespaces, :trial_ends_on, where: "trial_ends_on IS NOT NULL"
  end

  def down
    remove_concurrent_index(:namespaces, :trial_ends_on) if index_exists?(:namespaces, :trial_ends_on)
  end
end
