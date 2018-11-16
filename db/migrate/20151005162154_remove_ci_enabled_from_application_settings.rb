# rubocop:disable all
class RemoveCiEnabledFromApplicationSettings < ActiveRecord::Migration[4.2]
  def change
    remove_column :application_settings, :ci_enabled, :boolean, null: false, default: true
  end
end
