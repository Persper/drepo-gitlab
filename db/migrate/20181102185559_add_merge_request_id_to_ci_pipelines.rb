# frozen_string_literal: true

class AddMergeRequestIdToCiPipelines < ActiveRecord::Migration
  DOWNTIME = false

  def change
    add_reference :ci_pipelines, :merge_requests
    add_reference :ci_pipelines, :merge_requests, foreign_key: true
  end
end
