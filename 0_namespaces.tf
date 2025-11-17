# terraform import kubernetes_namespace.dns dns
resource "kubernetes_namespace" "dns" {
  metadata {
    name = "dns"
  }
}

# terraform import kubernetes_namespace.auth auth
resource "kubernetes_namespace" "auth" {
  metadata { name = "auth" }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}


resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
}


# terraform import kubernetes_namespace.monitoring mon
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "mon"
    labels = {
      name = "mon"
    }
  }
}
