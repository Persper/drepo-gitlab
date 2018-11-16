# rubocop:disable all
class AddUniqueIndexToNamespace < ActiveRecord::Migration[4.2]
  def change
    remove_index :namespaces, column: :name if index_exists?(:namespaces, :name)
    remove_index :namespaces, column: :path if index_exists?(:namespaces, :path)

    add_index :namespaces, :name, unique: true
    add_index :namespaces, :path, unique: true
  end
end
