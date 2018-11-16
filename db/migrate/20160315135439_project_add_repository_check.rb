# rubocop:disable all
class ProjectAddRepositoryCheck < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :last_repository_check_failed, :boolean
    add_index :projects, :last_repository_check_failed

    add_column :projects, :last_repository_check_at, :datetime
  end
end
