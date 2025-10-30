# Terraform manifest: monitoring-prometheus.tf

#########################
# Variables
#########################

#########################
# Namespaces
#########################
# terraform import kubernetes_namespace.monitoring monitoring

# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }

# terraform import helm_release.prometheus monitoring/prometheus
###########################
# Complete kube-prometheus-stack
###########################
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "79.0.1"

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          additionalScrapeConfigs = [
            {
              job_name = "macos-host"
              static_configs = [
                {
                  targets = ["host.docker.internal:9100"]
                }
              ]
            }
          ]
        }
      }
    })
  ]

  #depends_on = [helm_release.node_exporter]
}

#########################
# Outputs
#########################

output "grafana_admin_password" {
  value = "grafana password:\nkubectl -n monitoring get secrets prometheus-grafana -o json | jq '.data | map_values(@base64d)'"
}
