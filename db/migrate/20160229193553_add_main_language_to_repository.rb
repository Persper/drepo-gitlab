class AddMainLanguageToRepository < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :main_language, :string
  end
end
