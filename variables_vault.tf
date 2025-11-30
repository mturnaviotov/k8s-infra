# vault_admin_token
variable "vault_admin_token" {
  default = "root"
  type    = string
}

variable "vault_server_address" {
  default = "http://vault.vault.svc.cluster.local:8200"
  type    = string
}

variable "db_username" {
  description = "value"
  default     = "dbuser"
  type        = string
}

variable "db_password" {
  description = "value"
  default     = "12345"
  type        = string
}
