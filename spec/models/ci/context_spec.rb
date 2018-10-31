require 'spec_helper'

describe Ci::Context do
  it { is_expected.to belong_to(:project) }
end
