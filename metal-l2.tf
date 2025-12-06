# terraform import kubernetes_manifest.metallb_l2_advertisement 'apiVersion=metallb.io/v1beta1,kind=L2Advertisement,namespace=metallb-system,name=l2-advertisement'
resource "kubernetes_manifest" "metallb_l2_advertisement" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "L2Advertisement"
    "metadata" = {
      "annotations" = {
        "created-by" = "terraform"
      }
      "name"      = "l2-advertisement"
      "namespace" = kubernetes_namespace.ns["metallb-system"].metadata[0].name
    }
    "spec" = {
      "ipAddressPools" = [
        kubernetes_manifest.metallb_ip_pool.manifest.metadata["name"],
        kubernetes_manifest.metallb_dns_pool.manifest.metadata["name"],
      ]
    }
  }
}
