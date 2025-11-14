# Terraform manifest: keycloak.tf

###
### There no KeyCloak installation helm because it installed via bootstrapper
### yaml/keycloak.yaml
###
### kubectl apply -n auth -f https://raw.githubusercontent.com/keycloak/keycloak-quickstarts/refs/heads/main/kubernetes/keycloak.yaml

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
