resource "kubernetes_secret_v1" "oauth_grafana" {
  metadata {
    name      = "oauth-grafana"
    namespace = kubernetes_namespace_v1.ns["mon"].metadata[0].name
  }

  data = {
    OAUTH_CLIENT_SECRET = keycloak_openid_client.grafana.client_secret
  }

  type = "Opaque"
}

#client_secret: ${oidc_client_secret}
