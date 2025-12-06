variable "hostname" {
  description = "Ingress host name (e.g. jenkins.example.internal)"
  type        = string
}

variable "dns_zone" {
  description = "Private DNS zone name (without hostname)"
  type        = string
}

variable "service_name" {
  description = "Backend service name"
  type        = string
}

variable "service_port" {
  description = "Backend service port"
  type        = number
  default     = 80
}

variable "tls_secret_name" {
  description = "TLS secret name"
  type        = string
  default     = ""
}

variable "ingress_class" {
  description = "Ingress class (traefik)"
  type        = string
  default     = "traefik"
}

variable "cluster_issuer" {
  description = "Cluster issuer for cert-manager"
  type        = string
  default     = "local-ca"
}

variable "namespace" {
  description = "Kubernetes namespace for the ingress"
  type        = string
  default     = ""
}
