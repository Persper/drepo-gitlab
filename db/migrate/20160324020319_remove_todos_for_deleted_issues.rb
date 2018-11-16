class RemoveTodosForDeletedIssues < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      DELETE FROM todos
      WHERE todos.target_type = 'Issue'
        AND NOT EXISTS (
              SELECT *
              FROM issues
              WHERE issues.id = todos.target_id
                AND issues.deleted_at IS NULL
            )
    SQL
  end

  def down
  end
end
