require 'spec_helper'

describe Ci::Context do
  it 'is an abstract class that describes CI/CD context' do
    expect(described_class).to be_abstract_class
  end
end
