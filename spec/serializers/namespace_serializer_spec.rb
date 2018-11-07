require 'spec_helper'

describe NamespaceSerializer do
  it 'represents NamespaceEntity entities' do
    expect(described_class.entity_class).to eq(NamespaceEntity)
  end
end
