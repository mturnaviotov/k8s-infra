# Terraform manifest: monitoring-loki.tf

#########################
# Variables
#########################

#########################
# Namespaces
#########################

#########################
# Loki + Promtail (loki-stack)
#########################

resource "helm_release" "loki_stack" {
  name             = "loki-stack"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false
  values = [<<EOF
loki:
  enabled: true
promtail:
  enabled: true
  config:
    clients:
      - url: http://loki.${kubernetes_namespace.monitoring.metadata[0].name}.${var.dns_cluster_zone}:3100/loki/api/v1/push
EOF
  ]
}
