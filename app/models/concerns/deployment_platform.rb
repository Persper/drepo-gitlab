# frozen_string_literal: true

module DeploymentPlatform
  # EE would override this and utilize environment argument
  # rubocop:disable Gitlab/ModuleWithInstanceVariables
  def deployment_platform(environment: nil)
    @deployment_platform ||= {}

    @deployment_platform[environment] ||= find_deployment_platform(environment)
  end

  private

  def find_deployment_platform(environment)
    find_cluster_platform_kubernetes(environment: environment) ||
      find_group_cluster_platform_kubernetes_with_feature_guard(environment: environment) ||
      find_kubernetes_service_integration ||
      build_cluster_and_deployment_platform
  end

  # EE would override this and utilize environment argument
  def find_cluster_platform_kubernetes(environment: nil)
    clusters.enabled.default_environment
      .last&.platform_kubernetes
  end

  def find_group_cluster_platform_kubernetes_with_feature_guard(environment: nil)
    return nil unless Feature.enabled?(:deploy_group_clusters, default_enabled: true)

    find_group_cluster_platform_kubernetes(environment: environment)
  end

  # EE would override this and utilize environment argument
  def find_group_cluster_platform_kubernetes(environment: nil)
    group_clusters(Clusters::Cluster.enabled.default_environment)
      .last&.platform_kubernetes
  end

  def find_kubernetes_service_integration
    services.deployment.reorder(nil).find_by(active: true)
  end

  def build_cluster_and_deployment_platform
    return unless kubernetes_service_template

    cluster = ::Clusters::Cluster.create(cluster_attributes_from_service_template)
    cluster.platform_kubernetes if cluster.persisted?
  end

  def kubernetes_service_template
    @kubernetes_service_template ||= KubernetesService.active.find_by_template
  end

  def cluster_attributes_from_service_template
    {
      name: 'kubernetes-template',
      projects: [self],
      cluster_type: :project_type,
      provider_type: :user,
      platform_type: :kubernetes,
      platform_kubernetes_attributes: platform_kubernetes_attributes_from_service_template
    }
  end

  def platform_kubernetes_attributes_from_service_template
    {
      api_url: kubernetes_service_template.api_url,
      ca_pem: kubernetes_service_template.ca_pem,
      token: kubernetes_service_template.token,
      namespace: kubernetes_service_template.namespace
    }
  end

  def group_clusters(cluster_scope)
    Clusters::Cluster.belonging_to_parent_group_of_project(id, cluster_scope)
  end
end
