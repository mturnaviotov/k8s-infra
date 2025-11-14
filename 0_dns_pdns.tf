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
  values = [<<EOF
ingress:
  enabled: true
  host: pdns.${var.dns_private_zone_name}
  ClusterIP: "192.168.194.130"
  port: 8081
  annotations:
    kubernetes.io/ingress.className: traefik
    cert-manager.io/cluster-issuer: local-ca
    external-dns.alpha.kubernetes.io/hostname: pdns.${var.dns_private_zone_name}
    traefik.ingress.kubernetes.io/router.entrypoints: "web"
    traefik.ingress.kubernetes.io/router.priority: "10"

spec:
  ingressClassName: traefik
  tls:
  - hosts:
    - "pdns.${var.dns_private_zone_name}"
    secretName: "pdns-tls.${var.dns_private_zone_name}"
  rules:
  - host: "pdns.${var.dns_private_zone_name}"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: "pdns.${var.dns_private_zone_name}"
            port:
              number: 8081

apiPassword: &pdns_pass "${var.dns_server_password}"
pdns:
  apiPassword: *pdns_pass # Replace with your admin password from env vars or secret manager
  zones:
  - ${var.dns_private_zone_name}}
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
      cpu: "150m"
      memory: "512M"
    limits:
      cpu: "200m"
      memory: "1Gi"
  EOF
  ]
}
