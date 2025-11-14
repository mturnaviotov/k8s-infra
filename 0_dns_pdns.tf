# Terraform manifest: net-dns-pdns.tf

#########################
# Variables
#########################

#########################
# Namespaces
#########################

#########################
# PowerDNS from my custom chart
#########################

# terraform import helm_release.pdns dns/pdns
resource "helm_release" "pdns" {
  name             = "pdns"
  chart            = "https://github.com/mturnaviotov/k8s-pdns/releases/download/0.0.1/pdns-0.0.1.tgz"
  namespace        = kubernetes_namespace.dns.metadata[0].name
  create_namespace = false

  values = [templatefile("${path.module}/yaml/pdns.yaml", {
    zone_name = var.dns_private_zone_name
    password  = var.dns_server_password
    })
  ]

}

