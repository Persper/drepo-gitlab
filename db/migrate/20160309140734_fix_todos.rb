# rubocop:disable all
class FixTodos < ActiveRecord::Migration[4.2]
 def up
    execute <<-SQL
      DELETE FROM todos
      WHERE todos.target_type IN ('Commit', 'ProjectSnippet')
         OR NOT EXISTS (
              SELECT *
              FROM projects
              WHERE projects.id = todos.project_id
            )
    SQL
 end

 def down
 end
end
