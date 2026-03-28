##########################
# ArgoCD Root Application
##########################

# terraform import kubernetes_manifest.argocd_root_app 'apiVersion=argoproj.io/v1alpha1,kind=Application,namespace=argocd,name=root'
resource "kubernetes_manifest" "argocd_root_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "root"
      namespace = kubernetes_namespace_v1.ns["argocd"].metadata[0].name
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/mturnaviotov/k8s-argo.git"
        targetRevision = "main"
        path           = "root/"
      }
      destination = {
        server    = var.argocd_cluster_url
        namespace = kubernetes_namespace_v1.ns["argocd"].metadata[0].name
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
}
