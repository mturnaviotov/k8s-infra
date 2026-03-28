# terraform import 'kubernetes_namespace_v1.ns["jenkins"]' jenkins
variable "namespaces" {
  description = "namespaces"
  type        = list(string)
  default = ["argocd", "cert-manager", "dns", "ingress",
  "jenkins", "mon", "metallb-system"]
}

data "kubernetes_namespace_v1" "auth" {
  metadata {
    name = "auth"
  }
}

resource "kubernetes_namespace_v1" "ns" {
  for_each = toset(var.namespaces)
  metadata {
    name = each.key
    annotations = {
      managed-by = "terraform"
    }
  }
}
