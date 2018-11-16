require 'spec_helper'

describe Clusters::Applications::CheckInstallationProgressService do
  RESCHEDULE_PHASES = Gitlab::Kubernetes::Pod::PHASES - [Gitlab::Kubernetes::Pod::SUCCEEDED, Gitlab::Kubernetes::Pod::FAILED].freeze

  let(:application) { create(:clusters_applications_helm, :installing) }
  let(:service) { described_class.new(application) }
  let(:phase) { Gitlab::Kubernetes::Pod::UNKNOWN }
  let(:errors) { nil }

  shared_examples 'a terminated installation' do
    it 'removes the installation POD' do
      expect(service).to receive(:remove_installation_pod).once

      service.execute
    end
  end

  shared_examples 'a not yet terminated installation' do |a_phase|
    let(:phase) { a_phase }

    before do
      expect(service).to receive(:installation_phase).once.and_return(phase)
    end

    context "when phase is #{a_phase}" do
      context 'when not timeouted' do
        it 'reschedule a new check' do
          expect(ClusterWaitForAppInstallationWorker).to receive(:perform_in).once
          expect(service).not_to receive(:remove_installation_pod)

          service.execute

          expect(application).to be_installing
          expect(application.status_reason).to be_nil
        end
      end

      context 'when timeouted' do
        let(:application) { create(:clusters_applications_helm, :timeouted) }

        it_behaves_like 'a terminated installation'

        it 'make the application errored' do
          expect(ClusterWaitForAppInstallationWorker).not_to receive(:perform_in)

          service.execute

          expect(application).to be_errored
          expect(application.status_reason).to match(/\btimed out\b/)
        end
      end
    end
  end

  before do
    allow(service).to receive(:installation_errors).and_return(errors)
    allow(service).to receive(:remove_installation_pod).and_return(nil)
  end

  describe '#execute' do
    context 'when installation POD succeeded' do
      let(:phase) { Gitlab::Kubernetes::Pod::SUCCEEDED }

      before do
        expect(service).to receive(:installation_phase).once.and_return(phase)
      end

      it_behaves_like 'a terminated installation'

      it 'make the application installed' do
        expect(ClusterWaitForAppInstallationWorker).not_to receive(:perform_in)

        service.execute

        expect(application).to be_installed
        expect(application.status_reason).to be_nil
      end
    end

    context 'when installation POD failed' do
      let(:phase) { Gitlab::Kubernetes::Pod::FAILED }
      let(:errors) { 'test installation failed' }

      before do
        expect(service).to receive(:installation_phase).once.and_return(phase)
      end

      it_behaves_like 'a terminated installation'

      it 'make the application errored' do
        service.execute

        expect(application).to be_errored
        expect(application.status_reason).to eq("Installation failed")
      end
    end

    RESCHEDULE_PHASES.each { |phase| it_behaves_like 'a not yet terminated installation', phase }

    context 'when installation raises a Kubeclient::HttpError' do
      let(:cluster) { create(:cluster, :provided_by_user, :project) }

      before do
        application.update!(cluster: cluster)

        expect(service).to receive(:installation_phase).and_raise(Kubeclient::HttpError.new(401, 'Unauthorized', nil))
      end

      it 'shows the response code from the error' do
        service.execute

        expect(application).to be_errored
        expect(application.status_reason).to eq('Kubernetes error: 401')
      end
    end
  end
end
