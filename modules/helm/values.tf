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
  default     = null
}

variable "namespace" {
  description = "Namespace"
  type        = string
  default     = ""
}

variable "values" {
  description = "values"
  default     = []
}

variable "set" {
  description = "List of set"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

