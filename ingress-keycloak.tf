# Terraform manifest: keycloak.tf

#########################
# Variables
#########################
variable "name_keycloak" {
  default = "keycloak"
  type    = string
}

#########################
# Namespace
#########################

# terraform import kubernetes_namespace.auth auth
resource "kubernetes_namespace" "auth" {
  metadata { name = "auth" }
}

#########################
# Dashboard
#########################

# terraform import kubernetes_manifest.k8s_dashboard_ingress 'apiVersion=networking.k8s.io/v1,kind=Ingress,namespace=kubernetes-dashboard,name=dashboard-dns'
resource "kubernetes_manifest" "ingress_keycloak" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "ingress-${var.name_keycloak}"
      namespace = kubernetes_namespace.auth.metadata[0].name
      annotations = {
        "kubernetes.io/ingress.class"                      = "traefik"
        "cert-manager.io/cluster-issuer"                   = "local-ca"
        "external-dns.alpha.kubernetes.io/hostname"        = "${var.name_keycloak}.${var.dns_private_zone_name}"
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
      }
    }

    spec = {
      ingressClassName = "traefik"
      rules = [
        {
          host = "${var.name_keycloak}.${var.dns_private_zone_name}"
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = var.name_keycloak
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
          hosts      = ["${var.name_keycloak}.${var.dns_private_zone_name}"]
          secretName = "${var.name_keycloak}-tls"
        }
      ]
    }
  }

  depends_on = [kubernetes_namespace.auth]
}

