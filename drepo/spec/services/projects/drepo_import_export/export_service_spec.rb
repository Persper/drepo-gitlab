# frozen_string_literal: true

require 'spec_helper'

describe Projects::DrepoImportExport::ExportService do
  describe '#execute' do
    let!(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:shared) { project.drepo_import_export_shared }
    let(:project_snapshot) { create(:project_snapshot, project: project, author: user) }
    let(:params) { { project_snapshot_id: project_snapshot.id } }
    let(:service) { described_class.new(project, user, params) }
    let!(:after_export_strategy) { Gitlab::DrepoImportExport::AfterExportStrategies::DownloadNotificationStrategy.new }

    before do
      ::Snapshots::ProjectSnapshot.new(snapshot: project_snapshot, root_id: project_snapshot.project_id).create
      stub_ipfs_add
    end

    it 'saves the version' do
      expect(Gitlab::DrepoImportExport::VersionSaver).to receive(:new).and_call_original

      service.execute
    end

    it 'saves the avatar' do
      expect(Gitlab::DrepoImportExport::AvatarSaver).to receive(:new).and_call_original

      service.execute
    end

    it 'saves the models' do
      expect(Gitlab::DrepoImportExport::ProjectTreeSaver).to receive(:new).and_call_original

      service.execute
    end

    it 'saves the uploads' do
      expect(Gitlab::DrepoImportExport::UploadsSaver).to receive(:new).and_call_original

      service.execute
    end

    it 'saves the repo' do
      # once for the normal repo, once for the wiki
      expect(Gitlab::DrepoImportExport::RepoSaver).to receive(:new).twice.and_call_original

      service.execute
    end

    it 'saves the lfs objects' do
      expect(Gitlab::DrepoImportExport::LfsSaver).to receive(:new).and_call_original

      service.execute
    end

    it 'saves the wiki repo' do
      expect(Gitlab::DrepoImportExport::WikiRepoSaver).to receive(:new).and_call_original

      service.execute
    end

    context 'when all saver services succeed' do
      before do
        allow(service).to receive(:save_services).and_return(true)
      end

      it 'saves the project in the file system' do
        expect(Gitlab::DrepoImportExport::Saver).to receive(:save).with(project: project, shared: shared, params: params)

        service.execute
      end

      it 'calls the after export strategy' do
        expect(after_export_strategy).to receive(:execute)

        service.execute(after_export_strategy)
      end

      context 'when after export strategy fails' do
        before do
          allow(after_export_strategy).to receive(:execute).and_return(false)
        end

        after do
          service.execute(after_export_strategy)
        end

        it 'removes the remaining exported data' do
          allow(shared).to receive(:export_path).and_return('whatever')
          allow(FileUtils).to receive(:rm_rf)

          expect(FileUtils).to receive(:rm_rf).with(shared.export_path)
        end

        it 'notifies the user' do
          expect_any_instance_of(NotificationService).to receive(:project_not_exported)
        end

        it 'notifies logger' do
          allow(Rails.logger).to receive(:error)

          expect(Rails.logger).to receive(:error)
        end
      end
    end

    context 'when saver services fail' do
      before do
        allow(service).to receive(:save_services).and_return(false)
      end

      after do
        expect { service.execute }.to raise_error(Gitlab::DrepoImportExport::Error)
      end

      it 'removes the remaining exported data' do
        allow(shared).to receive(:export_path).and_return('whatever')
        allow(FileUtils).to receive(:rm_rf)

        expect(FileUtils).to receive(:rm_rf).with(shared.export_path)
      end

      it 'notifies the user' do
        expect_any_instance_of(NotificationService).to receive(:project_not_exported)
      end

      it 'notifies logger' do
        expect(Rails.logger).to receive(:error)
      end

      it 'the after export strategy is not called' do
        expect(service).not_to receive(:execute_after_export_action)
      end
    end
  end
end
