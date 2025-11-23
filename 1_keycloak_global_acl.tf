locals {
  groups = ["argocd-admin", "jenkins-admin", "grafana-admin"]
  user_map_to_groups = {
    user-admin = ["argocd-admin", "jenkins-admin", "grafana-admin"]
  }
}
######################
resource "keycloak_realm" "cluster" {
  realm         = var.keycloak_realm
  enabled       = true
  account_theme = "keycloak.v3"
  admin_theme   = "keycloak.v2"
  email_theme   = "base"
  login_theme   = "keycloak.v2"

  access_code_lifespan        = "1h"
  default_signature_algorithm = "RS256"
}

######################
# create groups
resource "keycloak_group" "groups" {
  for_each = toset(local.groups)
  realm_id = keycloak_realm.cluster.id
  name     = each.key
}

# create users
resource "keycloak_user" "users" {
  for_each       = local.user_map_to_groups
  realm_id       = keycloak_realm.cluster.id
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
resource "keycloak_user_groups" "user_map_to_groups" {
  for_each  = local.user_map_to_groups
  realm_id  = keycloak_realm.cluster.id
  user_id   = keycloak_user.users[each.key].id
  group_ids = [for g in each.value : keycloak_group.groups[g].id]
}
