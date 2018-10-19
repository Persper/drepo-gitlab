# frozen_string_literal: true

class PrometheusMetric < ActiveRecord::Base
  belongs_to :project, validate: true, inverse_of: :prometheus_metrics

  enum group: {
    # built-in groups
    nginx_ingress_vts: -1,
    ha_proxy: -2,
    aws_elb: -3,
    nginx: -4,
    kubernetes: -5,
    nginx_ingress: -6,

    # custom/user groups
    business: 0,
    response: 1,
    system: 2
  }

  validates :title, presence: true
  validates :query, presence: true
  validates :group, presence: true
  validates :y_label, presence: true
  validates :unit, presence: true

  validates :project, presence: true, unless: :common?
  validates :project, absence: true, if: :common?

  scope :common, -> { where(common: true) }

  GROUP_TITLES = {
    # built-in groups
    nginx_ingress_vts: _('Response metrics (NGINX Ingress VTS)'),
    nginx_ingress: _('Response metrics (NGINX Ingress)'),
    ha_proxy: _('Response metrics (HA Proxy)'),
    aws_elb: _('Response metrics (AWS ELB)'),
    nginx: _('Response metrics (NGINX)'),
    kubernetes: _('System metrics (Kubernetes)'),

    # custom/user groups
    business: _('Business metrics (Custom)'),
    response: _('Response metrics (Custom)'),
    system: _('System metrics (Custom)')
  }.freeze

  REQUIRED_METRICS = {
    nginx_ingress_vts: %w(nginx_upstream_responses_total nginx_upstream_response_msecs_avg),
    nginx_ingress: %w(nginx_ingress_controller_requests nginx_ingress_controller_ingress_upstream_latency_seconds_sum),
    ha_proxy: %w(haproxy_frontend_http_requests_total haproxy_frontend_http_responses_total),
    aws_elb: %w(aws_elb_request_count_sum aws_elb_latency_average aws_elb_httpcode_backend_5_xx_sum),
    nginx: %w(nginx_server_requests nginx_server_requestMsec),
    kubernetes: %w(container_memory_usage_bytes container_cpu_usage_seconds_total)
  }.freeze

  def group_title
    GROUP_TITLES[group.to_sym]
  end

  def required_metrics
    REQUIRED_METRICS[group.to_sym].to_a.map(&:to_s)
  end

  def to_query_metric
    Gitlab::Prometheus::Metric.new(id: id, title: title, required_metrics: required_metrics, weight: 0, y_label: y_label, queries: queries)
  end

  def queries
    [
      {
        query_range: query,
        unit: unit,
        label: legend,
        series: query_series
      }.compact
    ]
  end

  def query_series
    case legend
    when 'Status Code'
      [{
        label: 'status_code',
        when: [
          { value: '2xx', color: 'green' },
          { value: '4xx', color: 'orange' },
          { value: '5xx', color: 'red' }
        ]
      }]
    end
  end
end
