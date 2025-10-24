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