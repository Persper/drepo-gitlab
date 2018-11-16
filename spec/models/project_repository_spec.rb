# frozen_string_literal: true

require 'spec_helper'

describe ProjectRepository do
  describe 'associations' do
    it { is_expected.to belong_to(:shard) }
    it { is_expected.to have_one(:project) }
  end

  it 'can find project by disk path' do
    project = create(:project)

    expect(described_class.find_by(disk_path: project.disk_path)&.project).to eq(project)
  end
end
