require 'spec_helper'

describe Ci::Workspace do
  it { is_expected.to belong_to(:project) }
end
