variable "repo_name" {
  description = "Name of the ECR repository (usually <service>-api)."
  type        = string
}

variable "keep_last" {
  description = "How many images to retain via lifecycle policy."
  type        = number
  default     = 20
}

variable "scan_on_push" {
  description = "Enable ECR image scanning on push."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow Terraform to delete the repo even if it contains images."
  type        = bool
  default     = false
}
