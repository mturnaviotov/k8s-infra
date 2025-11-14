variable "name" {
  description = "Helm chart name"
  type        = string
  default     = ""
}

variable "repository" {
  description = "Repo url"
  type        = string
  default     = ""
}

variable "chart" {
  description = "Chart name"
  type        = string
  default     = ""
}

variable "chart_version" {
  description = "Chart version"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "Namespace"
  type        = string
  default     = ""
}

variable "values" {
  description = "values"
  default     = ""
}
