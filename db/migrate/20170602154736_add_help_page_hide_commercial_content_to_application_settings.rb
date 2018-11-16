# rubocop:disable Migration/SaferBooleanColumn
class AddHelpPageHideCommercialContentToApplicationSettings < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :application_settings, :help_page_hide_commercial_content, :boolean, default: false
  end
end
