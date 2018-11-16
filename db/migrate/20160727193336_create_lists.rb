# rubocop:disable Migration/Timestamps
class CreateLists < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :lists do |t|
      t.references :board, index: true, foreign_key: true, null: false
      t.references :label, index: true, foreign_key: true
      t.integer :list_type, null: false, default: 1
      t.integer :position

      t.timestamps null: false
    end
  end
end
