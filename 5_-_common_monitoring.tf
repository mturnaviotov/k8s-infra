# Terraform manifest: mon-_.tf

#########################
# Variables and common settings for monitoring and logging
#########################

#########################
# Namespaces
#########################

# terraform import kubernetes_namespace.monitoring monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata { name = "monitoring" }
}

# terraform import kubernetes_namespace.logging logging
# resource "kubernetes_namespace" "logging" {
#   metadata { name = "logging" }
# }
