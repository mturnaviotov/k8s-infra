# Terraform manifest: ingress-argocd.tf

####
####   Due to default ArgoCD server setup with HTTPS and self-signed certificate,
####   we euther need to setup proper TLS certs and ingress for ArgoCD server manually
####
#########################
# Variables
#########################

#########################
# Namespace
#########################

#########################
# ArgoCD Ingress
#########################

# terraform import kubernetes_manifest.ingress_argocd 'apiVersion=networking.k8s.io/v1,kind=Ingress,namespace=argocd,name=ingress-argocd'
resource "kubernetes_manifest" "ingress_argocd" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "ingress-argocd"
      namespace = kubernetes_namespace.argocd.metadata[0].name
      annotations = {
        "kubernetes.io/ingress.class"                      = "traefik"
        "cert-manager.io/cluster-issuer"                   = "local-ca"
        "external-dns.alpha.kubernetes.io/hostname"        = "argocd.${var.dns_private_zone_name}"
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
      }
    }

    spec = {
      ingressClassName = "traefik"
      rules = [
        {
          host = "argocd.${var.dns_private_zone_name}"
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "argocd-server"
                    port = {
                      number = 80
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
          hosts      = ["argocd.${var.dns_private_zone_name}"]
          secretName = "argocd-server-tls"
        }
      ]
    }
  }

  depends_on = [kubernetes_namespace.auth]
}
