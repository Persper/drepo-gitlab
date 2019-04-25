# frozen_string_literal: true

class SnapshotUpload < ApplicationRecord
  self.table_name = 'drepo_snapshot_uploads'

  include WithUploads
  include ObjectStorage::BackgroundMove

  belongs_to :snapshot

  # These hold the project Import/Export archives (.tar.gz files)
  mount_uploader :export_file, ImportExportUploader

  def retrieve_upload(_identifier, paths)
    Upload.find_by(model: self, path: paths)
  end
end
