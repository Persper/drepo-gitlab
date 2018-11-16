class RemoveWrongVersionsFromSchemaVersions < ActiveRecord::Migration[4.2]
  DOWNTIME = false

  def up
    execute("DELETE FROM schema_migrations WHERE version IN ('20170723183807', '20170724184243')")
  end

  def down
  end
end
