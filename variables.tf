# --- Host-based routing on :443 ---
variable "https_listener_arn" {
  description = "ARN of the shared HTTPS :443 listener from the ingress workspace."
  type        = string
  default     = null
}

variable "hostnames" {
  description = "FQDNs that should route to this service (e.g., [\"users.dev.ecolors.app\"])."
  type        = list(string)
  default     = []
}

variable "listener_rule_priority" {
  description = "Unique priority for the listener rule on :443 (1..50000). Required if creating the rule."
  type        = number
  default     = null
}

# Optional: let the service workspace create its own DNS record(s)
variable "create_dns_records" {
  description = "Create Route53 A/ALIAS records for hostnames to the env ALB."
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID that contains the hostnames (from ingress output)."
  type        = string
  default     = null
}

variable "alb_dns_name" {
  description = "ALB DNS name (from ingress output) used for alias targets."
  type        = string
  default     = null
}

variable "alb_zone_id" {
  description = "ALB zone ID (from ingress output) used for alias targets."
  type        = string
  default     = null
}
