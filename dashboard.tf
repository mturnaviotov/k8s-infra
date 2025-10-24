# Terraform manifest: keycloak.tf

#########################
# Variables
#########################

#########################
# Namespace
#########################

# terraform import kubernetes_namespace.k8s-dashboard kubernetes-dashboard
resource "kubernetes_namespace" "k8s-dashboard" {
  metadata { name = "kubernetes-dashboard" }
}

#########################
# Dashboard
#########################

# terraform import helm_release.kubernetes_dashboard kubernetes-dashboard/kubernetes-dashboard
resource "helm_release" "kubernetes_dashboard" {
  name             = "kubernetes-dashboard"
  namespace        = kubernetes_namespace.k8s-dashboard.metadata[0].name
  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
  version          = "7.13.0"
  create_namespace = false

  values = [
    yamlencode({
      protocolHttp = true
      service = {
        type = "ClusterIP"
      }
      ingress = {
        enabled = false
      }
      metricsScraper = {
        enabled = true
      }
    })
  ]
}

######################### !!!!!!!! DANGEROUS !!!!!!!!! #########################
# Dashboard Admin User and RoleBinding
# kubectl delete clusterrolebinding admin-user
# kubectl delete serviceaccount admin-user -n kubernetes-dashboard
##########################################################################

# terraform import -!- ns=`kubectl get ingressroute kubernetes-dashboard-route -n kubernetes-dashboard -o jsonpath='{.apiVersion}'`
# terraform import kubernetes_manifest.kubernetes_dashboard_ingressroute 'apiVersion=traefik.io/v1alpha1,kind=IngressRoute,namespace=kubernetes-dashboard,name=kubernetes-dashboard-route'
resource "kubernetes_manifest" "kubernetes_dashboard_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "kubernetes-dashboard-route"
      namespace = kubernetes_namespace.k8s-dashboard.metadata[0].name
    }

    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`board.${var.dns_private_zone_name}`)"
          kind  = "Rule"
          services = [
            {
              name = "kubernetes-dashboard-kong-proxy"
              port = 443
            }
          ]
        }
      ]
    }
  }

  depends_on = [helm_release.kubernetes_dashboard, helm_release.traefik]
}

# terraform import kubernetes_manifest.dashboard_admin_user 'apiVersion=v1,kind=ServiceAccount,namespace=kubernetes-dashboard,name=admin-user'
resource "kubernetes_manifest" "dashboard_admin_user" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"

    metadata = {
      name      = "admin-user"
      namespace = kubernetes_namespace.k8s-dashboard.metadata[0].name
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
        namespace = kubernetes_namespace.k8s-dashboard.metadata[0].name
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

output "k8s-dashboard_admin_user_bearer_token" {
  value      = "run kubectl -n kubernetes-dashboard create token admin-user\n, and paste the token to login to the dashboard"
  depends_on = [kubernetes_manifest.dashboard_admin_rolebinding]
}
