# frozen_string_literal: true

module Dg
  class ProjectSnapshotUpload < ApplicationRecord
    extend Gitlab::Dg::Model

    include WithUploads
    include ObjectStorage::BackgroundMove

    belongs_to :project_snapshot, class_name: 'Dg::ProjectSnapshot'

    # These hold the project Import/Export archives (.tar.gz files)
    mount_uploader :export_file, ImportExportUploader

    def retrieve_upload(_identifier, paths)
      Upload.find_by(model: self, path: paths)
    end
  end
end
