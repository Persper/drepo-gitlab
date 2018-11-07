require 'spec_helper'

describe ProviderRepoEntity do
  include ImportHelper

  let(:provider_repo) { { id: 1, full_name: 'full/name', name: 'name', owner: { login: 'owner' } } }
  let(:provider) { :github }
  let(:entity) { described_class.represent(provider_repo, provider: provider) }

  describe '#as_json' do
    subject { entity.as_json }

    it 'includes requried fields' do
      expect(subject[:id]).to eq(provider_repo[:id])
      expect(subject[:full_name]).to eq(provider_repo[:full_name])
      expect(subject[:owner_name]).to eq(provider_repo[:owner][:login])
      expect(subject[:sanitized_name]).to eq(sanitize_project_name(provider_repo[:name]))
      expect(subject[:provider_link]).to eq(provider_project_link_url(provider, provider_repo[:full_name]))
    end
  end
end
