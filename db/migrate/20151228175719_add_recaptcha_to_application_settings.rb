class AddRecaptchaToApplicationSettings < ActiveRecord::Migration[4.2]
  def change
    change_table :application_settings do |t|
      t.boolean :recaptcha_enabled, default: false
      t.string :recaptcha_site_key
      t.string :recaptcha_private_key
    end
  end
end
