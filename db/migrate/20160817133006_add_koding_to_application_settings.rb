# rubocop:disable Migration/SaferBooleanColumn
class AddKodingToApplicationSettings < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :application_settings, :koding_enabled, :boolean
    add_column :application_settings, :koding_url, :string
  end
end
