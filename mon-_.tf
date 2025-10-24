# Terraform manifest: monitoring-loki.tf

#########################
# Variables
#########################

variable "grafana_admin_password" {
  default = "prom-operator" # just default for our needs, net to be replaced in tuning
  type    = string
}

#########################
# Namespaces
#########################

resource "kubernetes_namespace" "monitoring" {
  metadata { name = "monitoring" }
}

# resource "kubernetes_namespace" "logging" {
#   metadata { name = "logging" }
# }
