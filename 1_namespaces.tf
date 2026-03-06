# terraform import 'kubernetes_namespace.ns["jenkins"]' jenkins
variable "namespaces" {
  description = "namespaces"
  type        = list(string)
  default = ["argocd", "auth", "cert-manager", "dns", "ingress",
  "jenkins", "mon", "metallb-system", "vault"]
}

resource "kubernetes_namespace" "ns" {
  for_each = toset(var.namespaces)
  metadata {
    name = each.key
    annotations = {
      managed-by = "terraform"
    }
  }
}
