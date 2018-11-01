# frozen_string_literal: true

class FillEmptyActionInDeployments < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  DEPLOYMENT_ACTION_START = 1
  DEPLOYMENT_ACTION_STOP = 2

  def up
    ActiveRecord::Base.connection.execute <<~SQL
      UPDATE
          "deployments"
      SET
          "action" = (CASE WHEN (SELECT true
                                 FROM ci_builds
                                 WHERE ci_builds.id = deployments.deployable_id
                                   AND ci_builds.options LIKE '%action: stop%') THEN #{DEPLOYMENT_ACTION_STOP}
                           ELSE #{DEPLOYMENT_ACTION_START}
                           END)
      WHERE
          "deployments"."action" IS NULL
    SQL
  end

  def down
    # no-op
  end
end
