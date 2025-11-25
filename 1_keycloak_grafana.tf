resource "keycloak_openid_client" "grafana" {
  realm_id                  = keycloak_realm.cluster.id
  client_id                 = "grafana"
  name                      = "grafana"
  enabled                   = true
  access_type               = "CONFIDENTIAL"
  standard_flow_enabled     = true
  always_display_in_console = true
  valid_redirect_uris = [
    "https://grafana.${var.dns_private_zone_name}/login/generic_oauth" #
  ]
}

resource "keycloak_openid_client_scope" "grafana_groups" {
  realm_id               = keycloak_realm.cluster.id
  name                   = "grafana_groups"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_openid_group_membership_protocol_mapper" "grafana_groups_mapper" {
  realm_id            = keycloak_realm.cluster.id
  client_scope_id     = keycloak_openid_client_scope.grafana_groups.id
  name                = "grafana_groups"
  claim_name          = "groups"
  full_path           = false
  add_to_access_token = true
  add_to_id_token     = true
  add_to_userinfo     = true
}

resource "keycloak_role" "keycloak_grafana_role_admin" {
  realm_id    = keycloak_realm.cluster.id
  client_id   = keycloak_openid_client.grafana.id
  name        = "admin"
  description = "Grafana admin role"
}

resource "keycloak_openid_client_default_scopes" "grafana_default_scopes" {
  realm_id  = keycloak_realm.cluster.id
  client_id = keycloak_openid_client.grafana.id
  default_scopes = [
    "profile",
    "email",
    "roles",
    "groups",
    "web-origins",
    keycloak_openid_client_scope.grafana_groups.name,
  ]
}
