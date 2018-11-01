# frozen_string_literal: true

class StealDigestColumn < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    Gitlab::BackgroundMigration.steal('DigestColumn')
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end
end
