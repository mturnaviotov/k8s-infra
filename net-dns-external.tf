# # ExternalDNS Helm release
# # terraform import helm_release.external_dns dns/external-dns
resource "helm_release" "external_dns" {
  name             = "external-dns"
  namespace        = kubernetes_namespace.dns.metadata[0].name
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = "1.18.0"
  create_namespace = false

  values = [
    yamlencode({
      provider   = var.dns_server_name
      txtOwnerId = "k8s-cluster"
      interval   = "1m"
      policy     = "upsert-only"
      sources = [
        "service",
        "ingress",
        "pod"
      ]
      logLevel = "debug"

      extraArgs = [
        "--pdns-server=http://pdns.${kubernetes_namespace.dns.metadata[0].name}.${var.dns_cluster_zone}:${var.dns_server_port}",
        "--pdns-server-id=localhost",
        "--pdns-api-key=${var.dns_server_password}",
        "--domain-filter=${var.dns_private_zone_name}",
        "--zone-name-filter=${var.dns_private_zone_name}",
        "--regex-domain-filter=${var.dns_private_zone_name}",
      ]
    })
  ]
}
