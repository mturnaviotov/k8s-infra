# Terraform manifest: jenkins.tf

#########################
# Variables
#########################

# Doesn't work with OIDC auth plugin
variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  default     = "admin"
  type        = string
}

variable "name_jenkins" {
  description = "Name for referencing service"
  default     = "jenkins"
  type        = string
}

# KeyCloak secrets for Jenkins OIDC client
variable "jenkins_keycloak_secret" {
  description = "Jenkins secret from client id"
  default     = "jenkins-keycloak-secret"
  type        = string
  sensitive   = true
}

variable "jenkins_keycloak_clientid" {
  description = "Jenkins client id in Keycloak"
  default     = "jenkins"
  type        = string
  sensitive   = true
}

# DockerHub credentials for Jenkins
variable "jenkins_dockerhub_login" {
  description = "DockerHub login/account for images push"
  default     = "dockerhub-login"
  type        = string
  sensitive   = true
}

variable "jenkins_dockerhub_password" {
  description = "DockerHub password for images push"
  default     = "dockerhub-password"
  type        = string
  sensitive   = true
}

#########################
# Namespaces
#########################

# terraform import kubernetes_namespace.jenkins jenkins
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

#########################
# Jenkins Helm Chart
#########################

# terraform import helm_release.jenkins jenkins/jenkins
resource "helm_release" "jenkins" {
  name             = var.name_jenkins
  repository       = "https://charts.jenkins.io"
  chart            = var.name_jenkins
  namespace        = kubernetes_namespace.jenkins.metadata[0].name
  create_namespace = false

  values = [templatefile("${path.module}/yaml/jenkins.yaml", {
    admin_password       = var.jenkins_admin_password
    admin_email          = "${var.name_jenkins}@${var.keycloak_realm}"
    dockerhub_login      = var.jenkins_dockerhub_login
    dockerhub_password   = var.jenkins_dockerhub_password
    oidc_client_secret   = keycloak_openid_client.argocd.client_secret
    jenkins_admin_group  = "jenkins_admin"
    jenkins_full_url     = "${var.name_jenkins}.${kubernetes_namespace.jenkins.metadata[0].name}.${var.dns_cluster_zone}"
    jenkins_url          = "${var.name_jenkins}.${var.dns_private_zone_name}"
    kubernetes_namespace = kubernetes_namespace.jenkins.metadata[0].name
    oidc_issuer          = "${var.name_keycloak}.${var.dns_private_zone_name}/realms/${var.keycloak_realm}"
    oidc_clientid        = var.jenkins_keycloak_clientid
    oidc_secret          = var.jenkins_keycloak_secret
    dns_zone             = var.dns_cluster_zone
    github_account       = var.github_account
    github_pat           = var.github_pat
    })
  ]

}

output "jenkins_admin_password" {
  value = "\n=====\nJenkins password is:\nkubectl -n ${kubernetes_namespace.jenkins.metadata[0].name} get secrets jenkins -o json | jq '.data | map_values(@base64d)'\n"
}
