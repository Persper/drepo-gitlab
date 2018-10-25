require 'spec_helper'

describe Ci::DeploymentSuccessWorker do
  subject { described_class.new.perform(deployment&.id) }

  context 'when deploy record exists' do
    let(:deployment) { create(:deployment) }

    it 'executes UpdateDeploymentService' do
      expect(UpdateDeploymentService)
        .to receive(:new).with(deployment).and_call_original

      subject
    end
  end

  context 'when deploy record does not exist' do
    let(:deployment) { nil }

    it 'executes UpdateDeploymentService' do
      expect(UpdateDeploymentService).not_to receive(:new)

      subject
    end
  end
end
