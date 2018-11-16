# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

# rubocop:disable RemoveIndex
class AddIncomingEmailTokenToUsers < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :users, :incoming_email_token, :string

    add_concurrent_index :users, :incoming_email_token
  end

  def down
    remove_index :users, :incoming_email_token if index_exists? :users, :incoming_email_token

    remove_column :users, :incoming_email_token
  end
end
