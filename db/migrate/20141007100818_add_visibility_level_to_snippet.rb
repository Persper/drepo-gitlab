# rubocop:disable all
class AddVisibilityLevelToSnippet < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  def up
    add_column :snippets, :visibility_level, :integer, :default => 0, :null => false

    execute("UPDATE snippets SET visibility_level = #{Gitlab::VisibilityLevel::PRIVATE} WHERE private = #{true_value}")
    execute("UPDATE snippets SET visibility_level = #{Gitlab::VisibilityLevel::INTERNAL} WHERE private = #{false_value}")

    add_index :snippets, :visibility_level

    remove_column :snippets, :private
  end

  def down
    add_column :snippets, :private, :boolean, :default => false, :null => false

    execute("UPDATE snippets SET private = #{false_value} WHERE visibility_level = #{Gitlab::VisibilityLevel::INTERNAL}")
    execute("UPDATE snippets SET private = #{true_value} WHERE visibility_level = #{Gitlab::VisibilityLevel::PRIVATE}")

    remove_column :snippets, :visibility_level
  end
end
