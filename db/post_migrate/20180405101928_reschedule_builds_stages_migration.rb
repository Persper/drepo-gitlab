class RescheduleBuildsStagesMigration < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  ##
  # Rescheduled `20180212101928_schedule_build_stage_migration.rb`
  #

  DOWNTIME = false
  MIGRATION = 'MigrateBuildStage'.freeze
  BATCH_SIZE = 500

  disable_ddl_transaction!

  class Build < ActiveRecord::Base
    include EachBatch
    self.table_name = 'ci_builds'
  end

  def up
    disable_statement_timeout do
      Build.where('stage_id IS NULL').tap do |relation|
        queue_background_migration_jobs_by_range_at_intervals(relation,
                                                              MIGRATION,
                                                              5.minutes,
                                                              batch_size: BATCH_SIZE)
      end
    end
  end

  def down
    # noop
  end
end
