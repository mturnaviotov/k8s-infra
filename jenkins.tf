# Terraform manifest: jenkins.tf

#########################
# Variables
#########################

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  default     = "admin"
}

#########################
# Namespaces
#########################

# terraform import kubernetes_namespace.dns dns
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

#########################
# Prometheus + Grafana (kube-prometheus-stack)
#########################

# terraform import helm_release.jenkins jenkins/jenkins
resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  namespace        = kubernetes_namespace.jenkins.metadata[0].name
  create_namespace = false

  values = [<<EOF
    controller:
      admin:
        password: "${var.jenkins_admin_password}"
      serviceType: "ClusterIP"
  EOF
  ]
}

output "jenkins_admin_password" {
  value = "password is:\nk -n ${kubernetes_namespace.jenkins.metadata[0].name} get secrets jenkins -o json | jq '.data | map_values(@base64d)'"
}

