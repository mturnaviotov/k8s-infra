locals {
  realm_id = "cluster"
  groups   = ["argocd-admin"]
  user_groups = {
    user-admin = ["argocd-admin"]
  }
}

resource "keycloak_openid_client" "argocd" {
  realm_id                  = var.keycloak_realm
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
  realm_id               = keycloak_openid_client.argocd.realm_id
  name                   = "groups"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_openid_group_membership_protocol_mapper" "argocd_groups_mapper" {
  realm_id        = keycloak_openid_client.argocd.realm_id
  client_scope_id = keycloak_openid_client_scope.argocd_groups.id
  name            = "groups"
  claim_name      = "groups"
  full_path       = false
}

# configure argocd openid client default scopes
resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
  realm_id  = keycloak_openid_client.argocd.realm_id
  client_id = keycloak_openid_client.argocd.id
  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.argocd_groups.name,
  ]
}

# create groups
resource "keycloak_group" "argocd_groups" {
  for_each = toset(local.groups)
  realm_id = keycloak_openid_client.argocd.realm_id
  name     = each.key
}

# create users
resource "keycloak_user" "argocd_users" {
  for_each       = local.user_groups
  realm_id       = keycloak_openid_client.argocd.realm_id
  username       = each.key
  enabled        = true
  email          = "argo@cluster"
  first_name     = each.key
  last_name      = each.key
  email_verified = true
  initial_password {
    value = each.key
  }
}

# configure use groups membership
resource "keycloak_user_groups" "user_groups" {
  for_each  = local.user_groups
  realm_id  = keycloak_openid_client.argocd.realm_id
  user_id   = keycloak_user.argocd_users[each.key].id
  group_ids = [for g in each.value : keycloak_group.argocd_groups[g].id]
} # output argocd openid client secret

# We will use it in Argo values for OIDC intergation
output "argocd_client-secret" {
  value     = keycloak_openid_client.argocd.client_secret
  sensitive = true
}
