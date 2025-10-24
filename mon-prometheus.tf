# Terraform manifest: monitoring-prometheus.tf

# Should be tuned

#########################
# Variables
#########################

#########################
# Namespaces
#########################

#########################
# Prometheus + Grafana (kube-prometheus-stack)
#########################

resource "helm_release" "grafana" {
  name             = "kube-prometheus-stack"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false
  values = [<<EOF
    prometheus:
      prometheusSpec: 
        serviceMonitorSelectorNilUsesHelmValues: false
    grafana:
      enabled: true
      adminPassword: ${var.grafana_admin_password}
    EOF
  ]
}

#### we already have node exporter in kube-prometheus-stack
# ------------------------------------------------------------------
# NODE EXPORTER
# ------------------------------------------------------------------
# resource "helm_release" "node_exporter" {
#   name       = "node-exporter"
#   namespace  = kubernetes_namespace.monitoring.metadata[0].name
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "prometheus-node-exporter"
#   #version    = "4.33.0"

#   create_namespace = false

#   values = [
#     yamlencode({
#       service = {
#         type = "ClusterIP"
#       }
#       hostRootFsMount = {
#         enabled = true
#       }
#       resources = {
#         limits = {
#           cpu    = "200m"
#           memory = "128Mi"
#         }
#         requests = {
#           cpu    = "50m"
#           memory = "64Mi"
#         }
#       }
#     })
#   ]
# }

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  #version    = "62.2.0"

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
  value = var.grafana_admin_password
}
