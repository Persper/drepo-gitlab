require 'spec_helper'
require 'fileutils'

describe Gitlab::DrepoImportExport::Saver do
  let!(:user) { create(:user) }
  let!(:project) { create(:project, :public, name: 'project') }
  let(:export_path) { "#{Dir.tmpdir}/project_tree_saver_spec" }
  let(:shared) { project.drepo_import_export_shared }
  let(:project_snapshot) { create(:project_snapshot, project: project, author: user, state: Dg::ProjectSnapshot::STATES[:snapped]) }
  let(:params) { { project_snapshot_id: project_snapshot.id } }

  subject { described_class.new(project: project, shared: shared, params: params) }

  before do
    allow_any_instance_of(Gitlab::DrepoImportExport).to receive(:storage_path).and_return(export_path)

    FileUtils.mkdir_p(shared.export_path)
    FileUtils.touch("#{shared.export_path}/tmp.bundle")
  end

  after do
    FileUtils.rm_rf(export_path)
  end

  it 'saves the repo using object storage and ipfs' do
    stub_uploads_object_storage(ImportExportUploader)
    stub_ipfs_add

    subject.save
    project_snapshot.reset

    expect(Dg::ProjectSnapshotUpload.find_by(project_snapshot: project_snapshot).export_file.url)
      .to match(%r[\/uploads\/-\/system\/dg\/project_snapshot_upload\/export_file.*])
    expect(project_snapshot.ipfs_file).to be_a Hash
    expect(project_snapshot.exported?).to be_truthy
  end
end
