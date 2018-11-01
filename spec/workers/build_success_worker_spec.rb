require 'spec_helper'

describe BuildSuccessWorker do
  describe '#perform' do
    subject { described_class.new.perform(build.id) }

    context 'when build exists' do
      context 'when deployment was not created when build was created because of transition period' do
        before do
          allow_any_instance_of(Deployment).to receive(:create_ref)
        end

        context 'when build belogs to the environment' do
          let!(:build) { create(:ci_build, :deploy_to_production) }

          before do
            Deployment.delete_all
          end

          it 'creates a successful deployment' do
            expect(build).not_to be_has_deployment

            subject

            build.reload
            expect(build).to be_has_deployment
            expect(build.deployment).to be_success
          end
        end

        context 'when build is not associated with project' do
          let!(:build) { create(:ci_build, project: nil) }

          it 'does not create deployment' do
            subject

            expect(build.reload).not_to be_has_deployment
          end
        end
      end
    end

    context 'when build does not exist' do
      it 'does not raise exception' do
        expect { described_class.new.perform(123) }
          .not_to raise_error
      end
    end
  end
end
