# brew install tfk8s
# kubectl get cm -n argocd argocd-cmd-params-cm -o yaml | tfk8s --strip -o sample.tf

# k -n argocd rollout restart deployment argocd-applicationset-controller argocd-notifications-controller argocd-repo-server argocd-server
resource "kubernetes_manifest" "configmap_argocd_argocd_cmd_params_cm" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ConfigMap"
    "metadata" = {
      "annotations" = {
        "meta.helm.sh/release-name"      = "argocd"
        "meta.helm.sh/release-namespace" = "argocd"
      }
      "labels" = {
        "app.kubernetes.io/component"  = "server"
        "app.kubernetes.io/instance"   = "argocd"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "argocd-cmd-params-cm"
        "app.kubernetes.io/part-of"    = "argocd"
        "helm.sh/chart"                = "argo-cd-9.1.3"
      }
      "name"      = "argocd-cmd-params-cm"
      "namespace" = "argocd"
    }

    "data" = {
      "applicationsetcontroller.enable.leader.election" = "false"
      "applicationsetcontroller.log.format"             = "json"
      "applicationsetcontroller.log.level"              = "info"
      "applicationcontroller.log.format"                = "json"
      "applicationcontroller.log.level"                 = "info"
      "commitserver.log.format"                         = "json"
      "commitserver.log.level"                          = "info"
      "controller.log.format"                           = "json"
      "controller.log.level"                            = "info"
      "dexserver.log.format"                            = "json"
      "dexserver.log.level"                             = "info"
      "notificationscontroller.log.format"              = "json"
      "notificationscontroller.log.level"               = "info"
      "redis.server"                                    = "argocd-redis:6379"
      "repo.server"                                     = "argocd-repo-server:8081"
      "reposerver.log.format"                           = "json"
      "reposerver.log.level"                            = "info"
      "server.log.format"                               = "json"
      "server.log.level"                                = "info"
      "server.repo.server.strict.tls"                   = "false"
      "server.insecure"                                 = "true"
    }
  }
}
