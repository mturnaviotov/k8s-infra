resource "keycloak_openid_client" "argocd" {
  realm_id                  = keycloak_realm.cluster.id
  client_id                 = "argocd"
  name                      = "argocd"
  enabled                   = true
  access_type               = "CONFIDENTIAL"
  standard_flow_enabled     = true
  always_display_in_console = true
  valid_redirect_uris = [
    "https://argocd.${var.dns_private_zone_name}/auth/callback"
  ]
}

resource "keycloak_openid_client_scope" "argocd_groups" {
  realm_id               = keycloak_realm.cluster.id
  name                   = "argocd_groups"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_openid_group_membership_protocol_mapper" "argocd_groups_mapper" {
  realm_id            = keycloak_realm.cluster.id
  client_scope_id     = keycloak_openid_client_scope.argocd_groups.id
  name                = "argocd_groups"
  claim_name          = "groups"
  full_path           = false
  add_to_access_token = true
  add_to_id_token     = true
  add_to_userinfo     = true
}

# configure argocd openid client default scopes
resource "keycloak_openid_client_default_scopes" "argocd_default_scopes" {
  realm_id  = keycloak_realm.cluster.id
  client_id = keycloak_openid_client.argocd.id
  default_scopes = [
    "profile",
    "email",
    "web-origins",
    keycloak_openid_client_scope.argocd_groups.name,
  ]
}
