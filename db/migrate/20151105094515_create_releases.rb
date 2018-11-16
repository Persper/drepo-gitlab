# rubocop:disable all
class CreateReleases < ActiveRecord::Migration[4.2]
  DOWNTIME = false

  def change
    create_table :releases do |t|
      t.string :tag
      t.text :description
      t.integer :project_id

      t.timestamps null: true
    end

    add_index :releases, :project_id
    add_index :releases, [:project_id, :tag]
  end
end
