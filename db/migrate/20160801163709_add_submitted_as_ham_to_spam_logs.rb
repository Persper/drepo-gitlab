# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddSubmittedAsHamToSpamLogs < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  # When a migration requires downtime you **must** uncomment the following
  # constant and define a short and easy to understand explanation as to why the
  # migration requires downtime.
  # DOWNTIME_REASON = ''

  disable_ddl_transaction!

  def up
    add_column_with_default :spam_logs, :submitted_as_ham, :boolean, default: false
  end

  def down
    remove_column :spam_logs, :submitted_as_ham
  end
end
