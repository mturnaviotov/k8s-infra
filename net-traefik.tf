# Terraform manifest: net-traefik.tf

#########################
# Variables
#########################

#########################
# Namespaces
#########################

# terraform import kubernetes_namespace.ingress ingress
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

#########################
# Traefik Helm Release
#########################

# terraform import helm_release.traefik ingress/traefik
resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://helm.traefik.io/traefik"
  chart            = "traefik"
  version          = "37.2.0"
  namespace        = kubernetes_namespace.ingress.metadata[0].name
  create_namespace = false

  values = [yamlencode({
    metadata = {
      annotations = {
        "cert-manager.io/cluster-issuer" : "local-ca"
        "external-dns.alpha.kubernetes.io/hostname" : "traefik.${var.dns_orb_zone}" #${var.dns_private_zone_name}"
    } }
    global = {
      checkNewVersion    = true
      sendAnonymousUsage = true
    }

    entryPoints = {
      web = {
        address = ":80"
      }
      websecure = {
        address = ":443"
      }
    }

    api = {
      dashboard = true
      insecure  = true
    }

    log = {
      level = "DEBUG"
    }

    accessLog = {}
  })]
}

# terraform import kubernetes_manifest.traefik_ingressroute 'apiVersion=traefik.io/v1alpha1,kind=IngressRoute,namespace=ingress,name=traefik-route'
resource "kubernetes_manifest" "traefik_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "traefik"
      namespace = kubernetes_namespace.ingress.metadata[0].name
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

  depends_on = [helm_release.traefik]
}
