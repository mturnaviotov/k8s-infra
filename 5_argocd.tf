# Terraform manifest: argocd.tf

#########################
# Variables
#########################

variable "argocd_cluster_name" {
  default = "in-cluster"
  type    = string
}

variable "argocd_cluster_url" {
  description = "ArgoCD cluster URL"
  type        = string
  default     = "https://kubernetes.default.svc"
}

#########################
# Service Account + RoleBinding
#########################

resource "kubernetes_service_account_v1" "argocd_access" {
  metadata {
    name      = "argocd-access"
    namespace = kubernetes_namespace_v1.ns["argocd"].metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "argocd_access_binding" {
  metadata {
    name = "argocd-access-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argocd_access.metadata[0].name
    namespace = kubernetes_service_account_v1.argocd_access.metadata[0].namespace
  }
}

# Token (1.24+)
resource "kubernetes_secret_v1" "argocd_access_token" {
  metadata {
    name      = "argocd-access-token"
    namespace = kubernetes_service_account_v1.argocd_access.metadata[0].namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.argocd_access.metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"
}

#########################
# ConfigMap (CA Cert)
#########################

data "kubernetes_config_map_v1" "kube_root_ca" {
  metadata {
    name      = "kube-root-ca.crt"
    namespace = kubernetes_namespace_v1.ns["argocd"].metadata[0].name
  }
}

#########################
# ArgoCD Cluster Secret
#########################

resource "kubernetes_secret_v1" "argocd_cluster_default" {
  metadata {
    name      = var.argocd_cluster_name
    namespace = kubernetes_namespace_v1.ns["argocd"].metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }

  data = {
    name   = var.argocd_cluster_name
    server = var.argocd_cluster_url
    config = jsonencode({
      bearerToken = kubernetes_secret_v1.argocd_access_token.data["token"]
      tlsClientConfig = {
        insecure = true
        # Uncomment to use CA cert, also you need to disable insecure in real world usage
        #caData   = base64encode(data.kubernetes_config_map.kube_root_ca.data["ca.crt"])
      }
    })
  }
}

#########################
# Outputs
#########################

output "argocd_initial_admin_password" {
  description = "Initial ArgoCD admin password (decoded)\n"
  value       = "\n=====\nArgoCD admin password:\nkubectl -n ${kubernetes_namespace_v1.ns["argocd"].metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode\n"
}

