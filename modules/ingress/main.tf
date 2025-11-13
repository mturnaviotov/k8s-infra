resource "kubernetes_manifest" "ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = var.hostname != "" ? var.hostname : "ingress-default"
      namespace = var.namespace != "" ? var.namespace : "default"
      annotations = {
        "kubernetes.io/ingress.class"                      = var.ingress_class
        "cert-manager.io/cluster-issuer"                   = var.cluster_issuer
        "external-dns.alpha.kubernetes.io/hostname"        = "${var.hostname}.${var.dns_zone}"
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
      }
    }

    spec = {
      ingressClassName = var.ingress_class
      rules = [
        {
          host = "${var.hostname}.${var.dns_zone}"
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = var.service_name
                    port = {
                      number = var.service_port
                    }
                  }
                }
              }
            ]
          }
        }
      ]

      tls = [
        {
          hosts      = ["${var.hostname}.${var.dns_zone}"]
          secretName = var.tls_secret_name != "" ? var.tls_secret_name : "${var.hostname}-tls"
        }
      ]
    }
  }
}
