# Terraform manifest: jenkins.tf

#########################
# Variables
#########################

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  default     = "admin"
}

variable "jenkins_name" {
  default = "jenkins"
  type    = string
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

# terraform import kubernetes_manifest.k8s_dashboard_ingress 'apiVersion=networking.k8s.io/v1,kind=Ingress,namespace=kubernetes-dashboard,name=dashboard-dns'
resource "kubernetes_manifest" "jenkins_ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "ingress-${var.jenkins_name}"
      namespace = kubernetes_namespace.jenkins.metadata[0].name
      annotations = {
        "kubernetes.io/ingress.class"                      = "traefik"
        "cert-manager.io/cluster-issuer"                   = "local-ca"
        "external-dns.alpha.kubernetes.io/hostname"        = "${var.jenkins_name}.${var.dns_private_zone_name}"
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
      }
    }

    spec = {
      ingressClassName = "traefik"
      rules = [
        {
          host = "${var.jenkins_name}.${var.dns_private_zone_name}"
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = var.jenkins_name
                    port = {
                      number = 8080
                    }
                  }
                }
              }
            ]
          }
        }
      ]

      tls = [
        {
          hosts      = ["${var.jenkins_name}.${var.dns_private_zone_name}"]
          secretName = "${var.jenkins_name}-tls"
        }
      ]
    }
  }

  depends_on = [kubernetes_namespace.jenkins]
}

output "jenkins_admin_password" {
  value = "password is:\nkubectl -n ${kubernetes_namespace.jenkins.metadata[0].name} get secrets jenkins -o json | jq '.data | map_values(@base64d)'"
}

