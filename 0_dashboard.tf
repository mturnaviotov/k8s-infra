# Terraform manifest: dashboard.tf

######################### !!!!!!!! DANGEROUS !!!!!!!!! #########################
# Dashboard Admin User and RoleBinding
# kubectl delete clusterrolebinding admin-user
# kubectl delete serviceaccount admin-user -n kubernetes-dashboard
##########################################################################

# terraform import kubernetes_manifest.dashboard_admin_user 'apiVersion=v1,kind=ServiceAccount,namespace=kubernetes-dashboard,name=admin-user'
resource "kubernetes_manifest" "dashboard_admin_user" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"

    metadata = {
      name      = "admin-user"
      namespace = kubernetes_namespace.ns["kubernetes-dashboard"].metadata[0].name
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [manifest]
  }
}

# terraform import kubernetes_manifest.dashboard_admin_rolebinding 'apiVersion=rbac.authorization.k8s.io/v1,kind=ClusterRoleBinding,name=admin-user'
resource "kubernetes_manifest" "dashboard_admin_rolebinding" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRoleBinding"
    metadata = {
      name = "admin-user"
    }
    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "admin-user"
        namespace = kubernetes_namespace.ns["kubernetes-dashboard"].metadata[0].name
      }
    ]
    roleRef = {
      kind     = "ClusterRole"
      name     = "cluster-admin"
      apiGroup = "rbac.authorization.k8s.io"
    }
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [manifest]
  }
  #depends_on = [kubernetes_manifest.dashboard_admin_user]
}

output "k8s-dashboard_bearer" {
  value = "\n=====\nJWT for Dashboard:\nkubectl -n ${kubernetes_namespace.ns["kubernetes-dashboard"].metadata[0].name} create token admin-user --duration=1999h\n, and paste the token to login to the dashboard UI\n"
}
