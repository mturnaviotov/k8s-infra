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
      entryPoints = ["web"]
      routes = [
        {
          match = "Host(`traefik.k8s.orb.local`)"
          kind  = "Rule"
          services = [
            {
              name = "api@internal"
              #port = 80
            }
          ]
        }
      ]
    }
  }

  depends_on = [helm_release.traefik]
}
