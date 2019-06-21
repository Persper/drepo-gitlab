# frozen_string_literal: true

class AddEthereumAddressesToUser < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  disable_ddl_transaction!

  # rubocop: disable Migration/AddColumn
  def change
    add_column :users, :ethereum_addresses, :string, array: true, default: []
  end
end
