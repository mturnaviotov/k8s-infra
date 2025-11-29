# terraform import 'kubernetes_namespace.ns["ingress"]' jenkins
variable "namespaces" {
  description = "namespaces"
  type        = list(string)
  default = ["argocd", "auth", "cert-manager", "dns", "ingress",
  "jenkins", "kubernetes-dashboard", "mon", "vault"]
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
