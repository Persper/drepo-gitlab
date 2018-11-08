require 'rails_helper'

describe ProjectImportState, type: :model do
  subject { create(:import_state) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:project) }
  end

  describe '#human_status_name' do
    context 'when import_state exists' do
      it 'returns the humanized status name' do
        import_state = create(:import_state, :started)

        expect(import_state.human_status_name).to eq("started")
      end
    end

    context 'when import_state was not created yet' do
      let(:import_state) { create(:import_state, :started) }

      it 'returns humanized status name' do
        expect(import_state.human_status_name).to eq("started")
      end
    end
  end

  describe 'import state transitions' do
    context 'state transition: [:started] => [:finished]' do
      let(:after_import_service) { spy(:after_import_service) }
      let(:housekeeping_service) { spy(:housekeeping_service) }

      before do
        allow(Projects::AfterImportService)
          .to receive(:new) { after_import_service }

        allow(after_import_service)
          .to receive(:execute) { housekeeping_service.execute }

        allow(Projects::HousekeepingService)
          .to receive(:new) { housekeeping_service }
      end

      it 'resets last_error' do
        error_message = 'Some error'
        import_state = create(:import_state, :started, last_error: error_message)

        expect { import_state.finish }.to change { import_state.last_error }.from(error_message).to(nil)
      end

      it 'performs housekeeping when an import of a fresh project is completed' do
        project = create(:project_empty_repo, :import_started, import_type: :github)

        project.import_state.finish

        expect(after_import_service).to have_received(:execute)
        expect(housekeeping_service).to have_received(:execute)
      end

      it 'does not perform housekeeping when project repository does not exist' do
        project = create(:project, :import_started, import_type: :github)

        project.import_state.finish

        expect(housekeeping_service).not_to have_received(:execute)
      end

      it 'does not perform housekeeping when project does not have a valid import type' do
        project = create(:project, :import_started, import_type: nil)

        project.import_state.finish

        expect(housekeeping_service).not_to have_received(:execute)
      end
    end
  end

  describe '#remove_jid', :clean_gitlab_redis_cache do
    let(:project) {  }

    context 'without an JID' do
      it 'does nothing' do
        import_state = create(:import_state)

        expect(Gitlab::SidekiqStatus)
          .not_to receive(:unset)

        import_state.remove_jid
      end
    end

    context 'with an JID' do
      it 'unsets the JID' do
        import_state = create(:import_state, jid: '123')

        expect(Gitlab::SidekiqStatus)
          .to receive(:unset)
          .with('123')
          .and_call_original

        import_state.remove_jid

        expect(import_state.jid).to be_nil
      end
    end
  end
end
