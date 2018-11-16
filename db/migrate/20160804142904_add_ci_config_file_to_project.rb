class AddCiConfigFileToProject < ActiveRecord::Migration[4.2]
  DOWNTIME = false

  def change
    add_column :projects, :ci_config_path, :string
  end

  def down
    remove_column :projects, :ci_config_path
  end
end
