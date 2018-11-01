# frozen_string_literal: true

class FillEmptyFinishedAtInDeployments < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  class Deployments < ActiveRecord::Base
    self.table_name = 'deployments'

    include EachBatch
  end

  def up
    FillEmptyFinishedAtInDeployments::Deployments
      .where('finished_at IS NULL')
      .each_batch(of: 10_000) do |relation|
      relation.update_all('finished_at=created_at')
    end
  end

  def down
    # no-op
  end
end
