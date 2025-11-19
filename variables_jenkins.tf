# # Terraform manifest: jenkins.tf

# #########################
# # Variables
# #########################

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

output "jenkins_admin_password" {
  value = "\n=====\nJenkins password is:\nkubectl -n ${kubernetes_namespace.ns["jenkins"].metadata[0].name} get secrets jenkins -o json | jq '.data | map_values(@base64d)'\n"
}
