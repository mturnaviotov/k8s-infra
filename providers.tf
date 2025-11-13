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
  default     = "orbstack"
}

#########################
# Terraform Providers
#########################

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.5.0"
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
  url           = var.keycloak_admin_url
  realm         = var.keycloak_admin_realm
  username      = var.keycloak_admin_username
  password      = var.keycloak_admin_password
}
