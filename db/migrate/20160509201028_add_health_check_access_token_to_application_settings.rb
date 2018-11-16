class AddHealthCheckAccessTokenToApplicationSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :application_settings, :health_check_access_token, :string
  end
end
