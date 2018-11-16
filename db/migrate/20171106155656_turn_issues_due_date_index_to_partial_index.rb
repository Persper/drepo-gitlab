# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class TurnIssuesDueDateIndexToPartialIndex < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  NEW_INDEX_NAME = 'idx_issues_on_project_id_and_due_date_and_id_and_state_partial'
  OLD_INDEX_NAME = 'index_issues_on_project_id_and_due_date_and_id_and_state'

  disable_ddl_transaction!

  def up
    add_concurrent_index(
      :issues,
      [:project_id, :due_date, :id, :state],
      where: 'due_date IS NOT NULL',
      name: NEW_INDEX_NAME
    )

    remove_concurrent_index_by_name(:issues, OLD_INDEX_NAME)
  end

  def down
    add_concurrent_index(
      :issues,
      [:project_id, :due_date, :id, :state],
      name: OLD_INDEX_NAME
    )

    remove_concurrent_index_by_name(:issues, NEW_INDEX_NAME)
  end
end
