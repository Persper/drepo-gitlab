class AddUniqueConstraintToCiVariables < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_ci_variables_on_project_id_and_key_and_environment_scope'

  disable_ddl_transaction!

  def up
    unless this_index_exists?
      add_concurrent_index(:ci_variables, columns, name: INDEX_NAME, unique: true)
    end
  end

  def down
    if this_index_exists?
      if Gitlab::Database.mysql? && !index_exists?(:ci_variables, :project_id)
        # Need to add this index for MySQL project_id foreign key constraint
        add_concurrent_index(:ci_variables, :project_id)
      end

      remove_concurrent_index(:ci_variables, columns, name: INDEX_NAME)
    end
  end

  private

  def this_index_exists?
    index_exists?(:ci_variables, columns, name: INDEX_NAME)
  end

  def columns
    @columns ||= [:project_id, :key, :environment_scope]
  end
end
