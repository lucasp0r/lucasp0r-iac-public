variable "config" {
  type = object({
    name     = string
    ca_data  = string
    endpoint = string
  })
  description = "cluster config"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "the kubernetes namespace to set"
}

variable "manifest" {
  type        = string
  description = "the kubernetes manifest to apply"
}

variable "apply" {
  type        = bool
  description = "Do nothing if false"
  default     = true
}

variable "replace" {
  type        = bool
  description = "Fall back to replace --force if apply fails"
  default     = false
}

variable "role_arn" {
  type        = string
  description = "IAM role to assume when authenticating with the EKS cluster, defaults to role assumed by aws provider config"
  default     = ""
}
