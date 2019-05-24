# frozen_string_literal: true

# rubocop:disable Migration/UpdateLargeTable
class AddIsUsernameVerifiedToUser < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false
  disable_ddl_transaction!

  def up
    add_column_with_default(:users, :is_username_verified, :boolean, default: false)
  end

  def down
    remove_column(:users, :is_username_verified)
  end
end
