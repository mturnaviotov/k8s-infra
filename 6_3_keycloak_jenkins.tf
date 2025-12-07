resource "keycloak_openid_client" "jenkins" {
  realm_id                  = keycloak_realm.cluster.id
  client_id                 = "jenkins"
  name                      = "jenkins"
  enabled                   = true
  access_type               = "CONFIDENTIAL"
  standard_flow_enabled     = true
  always_display_in_console = true
  valid_redirect_uris = [
    "https://jenkins.${var.dns_private_zone_name}/*"
  ]
}

resource "keycloak_openid_client_scope" "jenkins_groups" {
  realm_id               = keycloak_realm.cluster.id
  name                   = "jenkins_groups"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_openid_group_membership_protocol_mapper" "jenkins_groups_mapper" {
  realm_id            = keycloak_realm.cluster.id
  client_scope_id     = keycloak_openid_client_scope.jenkins_groups.id
  name                = "jenkins_groups"
  claim_name          = "groups"
  full_path           = false
  add_to_access_token = true
  add_to_id_token     = true
  add_to_userinfo     = true
}


resource "keycloak_openid_client_default_scopes" "jenkins_default_scopes" {
  realm_id  = keycloak_realm.cluster.id
  client_id = keycloak_openid_client.jenkins.id
  default_scopes = [
    "profile",
    "email",
    "roles",
    "groups",
    "web-origins",
    keycloak_openid_client_scope.jenkins_groups.name,
  ]
}
