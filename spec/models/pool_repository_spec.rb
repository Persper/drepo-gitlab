# frozen_string_literal: true

require 'spec_helper'

describe PoolRepository do
  describe 'associations' do
    it { is_expected.to belong_to(:shard) }
    it { is_expected.to have_many(:pool_member_projects) }
  end
end
