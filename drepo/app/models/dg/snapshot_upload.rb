# frozen_string_literal: true

module Dg
  class SnapshotUpload < ApplicationRecord
    extend Gitlab::Dg::Model

    include WithUploads
    include ObjectStorage::BackgroundMove

    belongs_to :snapshot, class_name: 'Dg::Snapshot'

    # These hold the project Import/Export archives (.tar.gz files)
    mount_uploader :export_file, ImportExportUploader

    def retrieve_upload(_identifier, paths)
      Upload.find_by(model: self, path: paths)
    end
  end
end
