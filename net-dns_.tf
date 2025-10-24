#########################
# Variables
#########################

variable "dns_private_zone_name" {
  description = "DNS zone name for CoreDNS and ExternalDNS integration"
  type        = string
  default     = "test.tld"
}

variable "dns_server_name" {
  default = "pdns"
  type    = string
}

variable "dns_server_password" {
  default   = "123123123"
  type      = string
  sensitive = true
}

variable "dns_server_port" {
  default = 8081
  type    = number
}

variable "dns_cluster_zone" {
  default = "svc.cluster.local"
  type    = string
}
#########################
# Namespaces
#########################

# terraform import kubernetes_namespace.dns dns
resource "kubernetes_namespace" "dns" {
  metadata {
    name = "dns"
  }
}
