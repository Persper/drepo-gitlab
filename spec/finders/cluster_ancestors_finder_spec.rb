# frozen_string_literal: true

require 'spec_helper'

describe ClusterAncestorsFinder do
  let(:group) { create(:group) }
  let(:project) { create(:project, group: group) }
end
