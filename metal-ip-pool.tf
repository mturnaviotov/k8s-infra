resource "kubernetes_manifest" "metallb_dns_pool" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "IPAddressPool"
    "metadata" = {
      "annotations" = {
        "created-by" = "terraform"
      }
      "name"      = "dns-pool"
      "namespace" = kubernetes_namespace.ns["metallb-system"].metadata[0].name
    }
    "spec" = {
      "addresses"     = var.metallb_dns_range
      "autoAssign"    = true
      "avoidBuggyIPs" = false
    }
  }
}

# terraform import kubernetes_manifest.metallb_ip_pool 'apiVersion=metallb.io/v1beta1,kind=IPAddressPool,namespace=metallb-system,name=ip-pool'
resource "kubernetes_manifest" "metallb_ip_pool" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "IPAddressPool"
    "metadata" = {
      "annotations" = {
        "created-by" = "terraform"
      }
      "name"      = "ip-pool"
      "namespace" = kubernetes_namespace.ns["metallb-system"].metadata[0].name
    }
    "spec" = {
      "addresses"     = var.metallb_ip_ranges
      "autoAssign"    = true
      "avoidBuggyIPs" = false
    }
  }
}
