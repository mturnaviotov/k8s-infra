##########################
# ArgoCD Application + Project
##########################

# terraform import kubernetes_manifest.argocd_project_todo 'apiVersion=argoproj.io/v1alpha1,kind=AppProject,namespace=argocd,name=todo'
resource "kubernetes_manifest" "argocd_project_todo" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "todo"
      namespace = kubernetes_namespace.ns["argocd"].metadata[0].name
    }
    spec = {
      description = "Todo application project for testing"
      sourceRepos = ["https://github.com/mturnaviotov/go-k8s-test-app.git"]
      destinations = [{
        namespace = "todo"
        server    = var.argocd_cluster_url
      }]
      clusterResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
      namespaceResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
    }
  }
}

# terraform import kubernetes_manifest.argocd_app_todo 'apiVersion=argoproj.io/v1alpha1,kind=Application,namespace=argocd,name=todo'
resource "kubernetes_manifest" "argocd_app_todo" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "todo"
      namespace = kubernetes_namespace.ns["argocd"].metadata[0].name
    }
    spec = {
      project = "todo"
      source = {
        repoURL        = "https://github.com/mturnaviotov/go-k8s-test-app.git"
        targetRevision = "HEAD"
        path           = "charts"
        helm = {
          valueFiles = ["values.yaml"]
        }
      }
      destination = {
        server    = var.argocd_cluster_url
        namespace = "todo"
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
