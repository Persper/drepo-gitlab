# frozen_string_literal: true

module Clusters
  class Cluster < ActiveRecord::Base
    include Presentable

    self.table_name = 'clusters'

    APPLICATIONS = {
      Applications::Helm.application_name => Applications::Helm,
      Applications::Ingress.application_name => Applications::Ingress,
      Applications::Prometheus.application_name => Applications::Prometheus,
      Applications::Runner.application_name => Applications::Runner,
      Applications::Jupyter.application_name => Applications::Jupyter
    }.freeze
    DEFAULT_ENVIRONMENT = '*'.freeze

    belongs_to :user

    has_many :cluster_projects, class_name: 'Clusters::Project'
    has_many :projects, through: :cluster_projects, class_name: '::Project'
    has_one :cluster_project, -> { order(id: :desc) }, class_name: 'Clusters::Project'

    has_many :cluster_groups, class_name: 'Clusters::Group'
    has_many :groups, through: :cluster_groups, class_name: '::Group'

    has_one :cluster_group, -> { order(id: :desc) }, class_name: 'Clusters::Group'
    has_one :group, through: :cluster_group, class_name: '::Group'

    # we force autosave to happen when we save `Cluster` model
    has_one :provider_gcp, class_name: 'Clusters::Providers::Gcp', autosave: true

    has_one :platform_kubernetes, class_name: 'Clusters::Platforms::Kubernetes', autosave: true

    has_one :application_helm, class_name: 'Clusters::Applications::Helm'
    has_one :application_ingress, class_name: 'Clusters::Applications::Ingress'
    has_one :application_prometheus, class_name: 'Clusters::Applications::Prometheus'
    has_one :application_runner, class_name: 'Clusters::Applications::Runner'
    has_one :application_jupyter, class_name: 'Clusters::Applications::Jupyter'

    has_many :kubernetes_namespaces
    has_one :kubernetes_namespace, -> { order(id: :desc) }, class_name: 'Clusters::KubernetesNamespace'

    accepts_nested_attributes_for :provider_gcp, update_only: true
    accepts_nested_attributes_for :platform_kubernetes, update_only: true

    validates :name, cluster_name: true
    validates :cluster_type, presence: true
    validate :restrict_modification, on: :update

    validate :no_groups, unless: :group_type?
    validate :no_projects, unless: :project_type?

    delegate :status, to: :provider, allow_nil: true
    delegate :status_reason, to: :provider, allow_nil: true
    delegate :on_creation?, to: :provider, allow_nil: true

    delegate :active?, to: :platform_kubernetes, prefix: true, allow_nil: true
    delegate :rbac?, to: :platform_kubernetes, prefix: true, allow_nil: true
    delegate :available?, to: :application_helm, prefix: true, allow_nil: true
    delegate :available?, to: :application_ingress, prefix: true, allow_nil: true
    delegate :available?, to: :application_prometheus, prefix: true, allow_nil: true

    enum cluster_type: {
      instance_type: 1,
      group_type: 2,
      project_type: 3
    }

    enum platform_type: {
      kubernetes: 1
    }

    enum provider_type: {
      user: 0,
      gcp: 1
    }

    scope :enabled, -> { where(enabled: true) }
    scope :disabled, -> { where(enabled: false) }
    scope :user_provided, -> { where(provider_type: ::Clusters::Cluster.provider_types[:user]) }
    scope :gcp_provided, -> { where(provider_type: ::Clusters::Cluster.provider_types[:gcp]) }
    scope :gcp_installed, -> { gcp_provided.includes(:provider_gcp).where(cluster_providers_gcp: { status: ::Clusters::Providers::Gcp.state_machines[:status].states[:created].value }) }

    scope :default_environment, -> { where(environment_scope: DEFAULT_ENVIRONMENT) }

    def self.belonging_to_parent_group_of_project(project_id, cluster_scope = all)
      project_groups = ::Group.joins(:projects).where(projects: { id: project_id })
      hierarchy_groups = Gitlab::GroupHierarchy.new(project_groups)
        .base_and_ancestors(depth: :desc)
        .joins(:clusters).merge(cluster_scope)

      hierarchy_groups.flat_map do |group|
        group.clusters.merge(cluster_scope)
      end
    end

    def status_name
      if provider
        provider.status_name
      else
        :created
      end
    end

    def created?
      status_name == :created
    end

    def applications
      [
        application_helm || build_application_helm,
        application_ingress || build_application_ingress,
        application_prometheus || build_application_prometheus,
        application_runner || build_application_runner,
        application_jupyter || build_application_jupyter
      ]
    end

    def provider
      return provider_gcp if gcp?
    end

    def platform
      return platform_kubernetes if kubernetes?
    end

    def managed?
      !user?
    end

    def first_project
      return @first_project if defined?(@first_project)

      @first_project = projects.first
    end
    alias_method :project, :first_project

    def kubeclient
      platform_kubernetes.kubeclient if kubernetes?
    end

    def find_or_initialize_kubernetes_namespace(cluster_project)
      kubernetes_namespaces.find_or_initialize_by(
        project: cluster_project.project,
        cluster_project: cluster_project
      )
    end

    private

    def restrict_modification
      if provider&.on_creation?
        errors.add(:base, "cannot modify during creation")
        return false
      end

      true
    end

    def no_groups
      if groups.any?
        errors.add(:cluster, 'cannot have groups assigned')
      end
    end

    def no_projects
      if projects.any?
        errors.add(:cluster, 'cannot have projects assigned')
      end
    end
  end
end
