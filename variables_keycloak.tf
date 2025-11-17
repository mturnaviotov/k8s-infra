
variable "name_keycloak" {
  description = "Name for referencing service"
  default     = "keycloak"
  type        = string
}

variable "keycloak_realm" {
  description = "Keycloak realm name"
  default     = "master"
  type        = string
}

variable "keycloak_admin_client_id" {
  description = "Keycloak admin client ID"
  type        = string
  default     = "admin-cli"
}
variable "keycloak_admin_client_secret" {
  description = "Keycloak admin client secret"
  type        = string
  default     = "secret-key" # secret from UI/master realm for admin-cli user
}
variable "keycloak_admin_url" {
  description = "Keycloak admin URL"
  type        = string
  default     = "http://localhost:8080"
}
variable "keycloak_admin_realm" {
  description = "Keycloak admin realm"
  type        = string
  default     = "master"
}
variable "keycloak_admin_username" {
  description = "Keycloak admin username"
  type        = string
  default     = "admin"
}
variable "keycloak_admin_password" {
  description = "Keycloak admin password"
  type        = string
  default     = "admin"
}

