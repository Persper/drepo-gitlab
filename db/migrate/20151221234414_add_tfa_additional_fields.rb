class AddTfaAdditionalFields < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.datetime :otp_grace_period_started_at, null: true
    end
  end
end
