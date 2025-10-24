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

resource "helm_release" "pdns" {
  name             = "pdns"
  chart            = "https://github.com/mturnaviotov/k8s-pdns/releases/download/0.0.1/pdns-0.0.1.tgz"
  namespace        = kubernetes_namespace.dns.metadata[0].name
  create_namespace = false
  values = [<<EOF
apiPassword: &pdns_pass "${var.dns_server_password}"
pdns:
  apiPassword: *pdns_pass # Replace with your admin password from env vars or secret manager
  env:
  - name: api_pdns
    value: "yes"
  - name: api-key_pdns
    value: *pdns_pass
  - name: zone-metadata-cache-ttl
    value: "60"
  - name: gsqlite3-database_pdns
    value: "/var/lib/powerdns/pdns.sqlite3"
  - name: launch_pdns
    value: "gsqlite3"
  - name: webserver_pdns
    value: "yes"
  - name: webserver-address_pdns
    value: "0.0.0.0"
  - name: webserver-allow-from_pdns
    value: "192.168.0.0/16,127.0.0.1,::1"
  - name: webserver-password_pdns
    value: *pdns_pass
  resources:
    requests:
      cpu: "500m"
      memory: "2Gi"
    limits:
      cpu: "2000m"
      memory: "4Gi"
  EOF
  ]
}
