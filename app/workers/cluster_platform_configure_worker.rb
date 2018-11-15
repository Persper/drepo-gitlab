# frozen_string_literal: true

class ClusterPlatformConfigureWorker
  include ApplicationWorker
  include ClusterQueue

  def perform(cluster_id)
    Clusters::Cluster.find_by_id(cluster_id).try do |cluster|
      if cluster.project_type?
        configure_for_project(cluster)
      elsif cluster.group_type?
        configure_for_group(cluster, cluster.group)
      end
    end

  rescue ::Kubeclient::HttpError => err
    Rails.logger.error "Failed to create/update Kubernetes namespace for cluster_id: #{cluster_id} with error: #{err.message}"
  end

  private

  def configure_for_project(cluster)
    return unless cluster.cluster_project

    kubernetes_namespace = cluster.find_or_initialize_kubernetes_namespace_by_cluster_project(cluster.cluster_project)

    Clusters::Gcp::Kubernetes::CreateOrUpdateNamespaceService.new(
      cluster: cluster,
      kubernetes_namespace: kubernetes_namespace
    ).execute
  end

  def configure_for_group(cluster, group)
    group.projects.each do |project|
      kubernetes_namespace = cluster.find_or_initialize_kubernetes_namespace_by_project(project)

      Clusters::Gcp::Kubernetes::CreateOrUpdateNamespaceService.new(
        cluster: cluster,
        kubernetes_namespace: kubernetes_namespace
      ).execute
    end

    group.children.each do |subgroup|
      configure_for_group(cluster, subgroup)
    end
  end
end
