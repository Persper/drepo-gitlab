class RenameApplicationSettingsPasswordAuthenticationEnabledToPasswordAuthenticationEnabledForWeb < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    rename_column_concurrently :application_settings, :password_authentication_enabled, :password_authentication_enabled_for_web
  end

  def down
    cleanup_concurrent_column_rename :application_settings, :password_authentication_enabled_for_web, :password_authentication_enabled
  end
end
