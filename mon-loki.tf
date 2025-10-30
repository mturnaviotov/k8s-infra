# Terraform manifest: mon-loki.tf

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
  schemaConfig:
    configs:
      - from: 2024-04-01
        store: tsdb
        object_store: s3
        schema: v13
        index:
          prefix: loki_index_
          period: 24h
  ingester:
    chunk_encoding: snappy
  tracing:
    enabled: true
  querier:
    # Default is 4, if you have enough memory and CPU you can increase, reduce if OOMing
    max_concurrent: 4

gateway:
ingress:
  enabled: true
  hosts:
    - host: "loki.${kubernetes_namespace.monitoring.metadata[0].name}.${var.dns_cluster_zone}"
      paths:
        - path: /
          pathType: Prefix

deploymentMode: singleBinary

singleBinary:
  replicas: 1
EOF
  ]
}

# loki:
#   enabled: true
# promtail:
#   enabled: true
#   config:
#     clients:
#       - url: http://loki.${kubernetes_namespace.monitoring.metadata[0].name}.${var.dns_cluster_zone}:3100/loki/api/v1/push
