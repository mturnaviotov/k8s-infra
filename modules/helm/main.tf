resource "helm_release" "app" {
  name             = var.name
  repository       = var.repository
  chart            = var.chart
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = false
  values           = var.values
  set              = var.set
  take_ownership   = true

  disable_openapi_validation = true
}
