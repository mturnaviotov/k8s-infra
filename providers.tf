# Terraform manifest: providers.tf

#########################
# Variables
#########################

variable "kubeconfig_path" {
  description = "Path to kubeconfig file (or set KUBECONFIG env)."
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubeconfig context to use."
  type        = string
  default     = "kind-basic"
}

#########################
# Terraform Providers
#########################

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.1"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.7.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.8.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.kubeconfig_context
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "keycloak" {
  client_id     = var.keycloak_admin_client_id
  client_secret = var.keycloak_admin_client_secret
  url           = var.keycloak_admin_url # "http://keycloak.(namespace).svc.cluster.local:8080"
  realm         = var.keycloak_admin_realm
  username      = var.keycloak_admin_username
  password      = var.keycloak_admin_password
}

provider "vault" {
  # Configuration options
  address = var.vault_server_address
  token   = var.vault_admin_token
}
