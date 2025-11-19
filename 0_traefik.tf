# Terraform manifest: net-traefik.tf

# terraform import kubernetes_manifest.traefik_ingressroute 'apiVersion=traefik.io/v1alpha1,kind=IngressRoute,namespace=ingress,name=traefik-route'
resource "kubernetes_manifest" "traefik_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "traefik"
      namespace = kubernetes_namespace.ns["ingress"].metadata[0].name
    }
    spec = {
      entryPoints = ["web", "websecure"]
      routes = [
        {
          match = "Host(`traefik.${var.dns_orb_zone}`)"
          kind  = "Rule"
          services = [
            {
              name = "api@internal"
              port = 80
              kind = "TraefikService"
            }
          ]
        }
      ]
    }
  }
}
