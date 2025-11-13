# Terraform manifest: keycloak.tf

#########################
# Variables
#########################
variable "name_keycloak" {
  description = "Name for referencing service"
  default     = "keycloak"
  type        = string
}

variable "keycloak_realm" {
  description = "Keycloak realm name"
  default     = "master"
  type        = string
}

#########################
# Namespace
#########################

# terraform import kubernetes_namespace.auth auth
resource "kubernetes_namespace" "auth" {
  metadata { name = "auth" }
}

#########################
# Keycloak Ingress
# Keycloak should be installed separately, e.g., via Official or custom Helm chart
# kubectl apply -n auth -f https://raw.githubusercontent.com/keycloak/keycloak-quickstarts/refs/heads/main/kubernetes/keycloak.yaml
#########################

