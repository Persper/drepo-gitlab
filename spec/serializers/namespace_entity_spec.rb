require 'spec_helper'

describe NamespaceEntity do
  set(:group) { create(:group) }
  let(:entity) do
    described_class.represent(group)
  end

  describe '#as_json' do
    subject { entity.as_json }

    it 'includes required fields' do
      expect(subject).to include :id, :path
    end
  end
end
