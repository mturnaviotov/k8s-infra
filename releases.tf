locals {

  helm_charts = {
    "traefik" = {
      name       = "traefik"
      repository = "https://helm.traefik.io/traefik"
      chart      = "traefik"
      version    = "37.3.0"
      namespace  = kubernetes_namespace.ingress.metadata[0].name

      values = [templatefile("${path.module}/yaml/traefik.yaml", {
        dns_zone = var.dns_orb_zone
        })
      ]
    }
    "pdns" = {
      name      = "pdns"
      chart     = "https://github.com/mturnaviotov/k8s-pdns/releases/download/0.0.3/pdns-0.0.3.tgz"
      namespace = kubernetes_namespace.dns.metadata[0].name
      version   = "0.0.3"
      values = [templatefile("${path.module}/yaml/pdns.yaml", {
        zone_name = var.dns_private_zone_name
        password  = var.dns_server_password
      })]
    }
    "argocd" = {
      name       = "argocd"
      repository = "https://argoproj.github.io/argo-helm"
      chart      = "argo-cd"
      namespace  = kubernetes_namespace.argocd.metadata[0].name
      version    = "9.1.3"

      values = [templatefile("${path.module}/yaml/argocd.yaml", {
        clientID           = "argocd"
        oidc_client_secret = keycloak_openid_client.argocd.client_secret
        issuer             = "https://${var.name_keycloak}.${var.dns_private_zone_name}/realms/${var.keycloak_realm}"
        admin_groups       = ["argocd-admin"]
        })
      ]
    }
    "cert-manager" = {
      name      = "cert-manager"
      chart     = "oci://quay.io/jetstack/charts/cert-manager"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
      version   = "v1.19.1"

      set = [
        {
          name : "prometheus.enabled",
          value : "true"
        },
        {
          name  = "installCRDs"
          value = "true"
        }
      ]
    }
  }
}

# terraform import example
# #terraform import module.ingress_dashboard.kubernetes_manifest.ingress 'apiVersion=networking.k8s.io/v1,kind=Ingress,namespace=kubernetes-dashboard,name=ingress-dashboard'

module "helm" {
  for_each = local.helm_charts

  source = "./modules/helm"

  name          = each.key
  chart         = lookup(each.value, "chart", "")
  repository    = lookup(each.value, "repository", "")
  chart_version = lookup(each.value, "version", "")
  namespace     = each.value.namespace
  values        = lookup(each.value, "values", [])
  set           = lookup(each.value, "set", [])
}
