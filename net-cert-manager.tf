# Terraform manifest: net-cert-manager.tf

#########################
# Variables
#########################

#########################
# Namespaces
#########################

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}
#########################
# Cert Manager Helm Release
#########################

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  chart            = "oci://quay.io/jetstack/charts/cert-manager"
  namespace        = kubernetes_namespace.cert_manager.metadata[0].name
  version          = "v1.19.1"
  create_namespace = false
  values = [<<EOF
  prometheus:
    enabled: true
  EOF
  ]
}

#########################
# Local CA Cluster Issuer
#########################

# You need to create the CA cert and key files before applying this terraform:
# openssl req -x509 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 365 -nodes #-subj "/CN=local-ca"
resource "kubernetes_secret" "local_ca_key_pair" {
  type = "kubernetes.io/tls"

  metadata {
    name      = "local-ca-key-pair"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }

  data = {
    "tls.crt" = file("${path.module}/ca.crt")
    "tls.key" = file("${path.module}/ca.key")
  }

  depends_on = [
    helm_release.cert_manager
  ]
}

resource "kubernetes_manifest" "cluster_issuer_local_ca" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "local-ca"
    }
    spec = {
      ca = {
        secretName = kubernetes_secret.local_ca_key_pair.metadata[0].name
      }
    }
  }

  depends_on = [
    helm_release.cert_manager,
    kubernetes_secret.local_ca_key_pair
  ]
}
