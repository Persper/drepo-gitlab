class AddArtifactsStoreToCiBuild < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column(:ci_builds, :artifacts_file_store, :integer)
    add_column(:ci_builds, :artifacts_metadata_store, :integer)
  end
end
