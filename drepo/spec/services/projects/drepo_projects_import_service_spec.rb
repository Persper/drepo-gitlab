# frozen_string_literal: true

require 'spec_helper'

describe Projects::DrepoProjectsImportService do
  set(:namespace) { create(:namespace) }
  let(:path) { 'test-path' }
  let(:ipfs_path) { "a hash" }
  let(:overwrite) { false }
  let(:import_params) do
    {
      namespace_id: namespace.id,
      path: path,
      ipfs_path: ipfs_path,
      overwrite: overwrite
    }
  end

  before do
    stub_ipfs_cat('spec/fixtures/project_export.tar.gz')
  end

  subject { described_class.new(namespace.owner, import_params) }

  describe '#execute' do
    it_behaves_like 'gitlab projects import validations'
  end
end
