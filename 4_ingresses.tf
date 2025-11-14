locals {

  ingresses = {
    "board" = {
      namespace    = kubernetes_namespace.k8s-dashboard.metadata[0].name
      service_name = "kubernetes-dashboard-web"
      service_port = 8000
    }
    "argocd" = {
      namespace    = kubernetes_namespace.argocd.metadata[0].name
      service_name = "argocd-server"
      service_port = 80
    }
    "jenkins" = {
      namespace    = kubernetes_namespace.jenkins.metadata[0].name
      service_name = "jenkins"
      service_port = 8080
    }
    "keycloak" = {
      namespace    = kubernetes_namespace.auth.metadata[0].name
      service_name = "keycloak"
      service_port = 8080
    }
    # we have static ip via for pdns, no ingress needed
    # "pdns" = {
    #   namespace    = kubernetes_namespace.pdns.metadata[0].name
    #   service_name = "pdns"
    #   service_port = 8081
    # }
  }
}

# terraform import example
# #terraform import module.ingress_dashboard.kubernetes_manifest.ingress 'apiVersion=networking.k8s.io/v1,kind=Ingress,namespace=kubernetes-dashboard,name=ingress-dashboard'

module "ingress" {
  for_each = local.ingresses

  source       = "./modules/ingress"
  hostname     = each.key
  namespace    = each.value.namespace
  dns_zone     = var.dns_private_zone_name
  service_name = each.value.service_name
  service_port = each.value.service_port
}
