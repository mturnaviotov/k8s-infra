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

# terraform import helm_release.loki_stack monitoring/loki-stack
resource "helm_release" "loki_stack" {
  name             = "loki-stack"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false

  values = [templatefile("${path.module}/yaml/loki.yaml", {
    host = "loki.${kubernetes_namespace.monitoring.metadata[0].name}.${var.dns_cluster_zone}"
    })
  ]

}
