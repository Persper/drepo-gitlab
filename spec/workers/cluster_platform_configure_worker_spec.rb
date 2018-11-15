# frozen_string_literal: true

require 'spec_helper'

describe ClusterPlatformConfigureWorker, '#perform' do
  let(:worker) { described_class.new }

  context 'when group cluster' do
    let(:cluster) { create(:cluster, :group, :provided_by_gcp) }
    let(:group) { cluster.group }

    context 'when group has no projects' do
      it 'does not create a namespace' do
        expect_any_instance_of(Clusters::Gcp::Kubernetes::CreateOrUpdateNamespaceService).not_to receive(:execute)

        worker.perform(cluster.id)
      end
    end

    context 'when group has a project' do
      let!(:project) { create(:project, group: group) }

      it 'creates a namespace for the project' do
        expect_any_instance_of(Clusters::Gcp::Kubernetes::CreateOrUpdateNamespaceService).to receive(:execute).once

        worker.perform(cluster.id)
      end
    end

    context 'when group has project in a sub-group' do
      let!(:subgroup) { create(:group, parent: group) }
      let!(:project) { create(:project, group: subgroup) }

      it 'creates a namespace for the project' do
        expect_any_instance_of(Clusters::Gcp::Kubernetes::CreateOrUpdateNamespaceService).to receive(:execute).once

        worker.perform(cluster.id)
      end
    end
  end

  context 'when provider type is gcp' do
    let(:cluster) { create(:cluster, :project, :provided_by_gcp) }

    it 'configures kubernetes platform' do
      expect_any_instance_of(Clusters::Gcp::Kubernetes::CreateOrUpdateNamespaceService).to receive(:execute)

      described_class.new.perform(cluster.id)
    end
  end

  context 'when provider type is user' do
    let(:cluster) { create(:cluster, :project, :provided_by_user) }

    it 'configures kubernetes platform' do
      expect_any_instance_of(Clusters::Gcp::Kubernetes::CreateOrUpdateNamespaceService).to receive(:execute)

      described_class.new.perform(cluster.id)
    end
  end

  context 'when cluster does not exist' do
    it 'does not provision a cluster' do
      expect_any_instance_of(Clusters::Gcp::Kubernetes::CreateOrUpdateNamespaceService).not_to receive(:execute)

      described_class.new.perform(123)
    end
  end

  context 'when kubeclient raises error' do
    let(:cluster) { create(:cluster, :project) }

    it 'rescues and logs the error' do
      allow_any_instance_of(Clusters::Gcp::Kubernetes::CreateOrUpdateNamespaceService).to receive(:execute).and_raise(::Kubeclient::HttpError.new(500, 'something baaaad happened', ''))

      expect(Rails.logger)
        .to receive(:error)
        .with("Failed to create/update Kubernetes namespace for cluster_id: #{cluster.id} with error: something baaaad happened")

      described_class.new.perform(cluster.id)
    end
  end
end
