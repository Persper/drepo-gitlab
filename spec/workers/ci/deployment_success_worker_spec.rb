require 'spec_helper'

describe Ci::DeploymentSuccessWorker do
  subject { described_class.new.perform(deployment.id) }

  describe '#execute' do
    let(:environment) { create(:environment) }
    let!(:deployment) { create(:deployment, environment: environment) }
    let(:store) { Gitlab::EtagCaching::Store.new }

    it 'invalidates the environment etag cache' do
      old_value = store.get(environment.etag_cache_key)

      subject

      expect(store.get(environment.etag_cache_key)).not_to eq(old_value)
    end
  end
end
