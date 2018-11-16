class AddDefaultArtifactsExpirationToApplicationSettings < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :application_settings,
      :default_artifacts_expire_in, :string,
      null: false, default: '0'
  end
end
