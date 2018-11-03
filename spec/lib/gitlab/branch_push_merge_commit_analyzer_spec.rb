# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::BranchPushMergeCommitAnalyzer do
  let(:project) { create(:project, :repository) }
  let(:oldrev) { 'merge-commit-analyze-before' }
  let(:newrev) { 'merge-commit-analyze-after' }

  subject { described_class.new(project.repository.commits_between(oldrev, newrev)) }

  describe '#get_merge_commit' do
    it 'returns correct merge commit SHA for each commit' do
      expected_merge_commits = {
        '646ece5cfed840eca0a4feb21bcd6a81bb19bda3' => '646ece5cfed840eca0a4feb21bcd6a81bb19bda3',
        '29284d9bcc350bcae005872d0be6edd016e2efb5' => '29284d9bcc350bcae005872d0be6edd016e2efb5',
        '5f82584f0a907f3b30cfce5bb8df371454a90051' => '29284d9bcc350bcae005872d0be6edd016e2efb5',
        '8a994512e8c8f0dfcf22bb16df6e876be7a61036' => '29284d9bcc350bcae005872d0be6edd016e2efb5',
        '689600b91aabec706e657e38ea706ece1ee8268f' => '29284d9bcc350bcae005872d0be6edd016e2efb5',
        'db46a1c5a5e474aa169b6cdb7a522d891bc4c5f9' => 'db46a1c5a5e474aa169b6cdb7a522d891bc4c5f9'
      }

      expected_merge_commits.each do |commit, merge_commit|
        expect(subject.get_merge_commit(commit)).to eq(merge_commit)
      end
    end
  end
end
