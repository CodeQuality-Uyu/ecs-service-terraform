variable "aws_region"            { type = string }
variable "aws_access_key"        { type = string }
variable "aws_secret_key"        { type = string }

variable "name"                  { description = "Service name"; type = string }
variable "tags"                  { description = "Common tags";  type = map(string); default = {} }

variable "cluster_arn"           { description = "Existing ECS cluster ARN"; type = string }
variable "subnet_ids"            { description = "Subnets for awsvpc"; type = list(string) }
variable "vpc_id"                { description = "VPC ID (for TG + SG)"; type = string }
variable "assign_public_ip"      { description = "Assign public IP to tasks"; type = bool; default = true }

# Sizing
variable "cpu"                   { description = "Task CPU units"; type = number }
variable "memory"                { description = "Task memory (MiB)"; type = number }
variable "container_port"        { description = "Container port"; type = number }
variable "desired_count"         { description = "Desired tasks"; type = number; default = 1 }

# Image
variable "image"                 { description = "Full image URI (optional)"; type = string; default = null }
variable "repository_url"        { description = "ECR repo URL"; type = string; default = null }
variable "image_tag"             { description = "Image tag"; type = string; default = "latest" }

# Env & Secrets
variable "env"                   { description = "Environment variables"; type = map(string); default = {} }
variable "secrets" {
  description = "Container secrets (name/valueFrom ARN)"
  type = list(object({ name = string, valueFrom = string }))
  default = []
}

# IAM (optional create)
variable "execution_role_arn"    { type = string, default = null }
variable "create_execution_role" { type = bool,   default = true  }
variable "task_role_arn"         { type = string, default = null }
variable "task_role_inline_policy_json" { type = string, default = null }

# Logs
variable "log_retention_days"    { type = number, default = 14 }

# Exposure / SG
variable "expose_via_alb"        { type = bool,   default = true }
variable "alb_security_group_id" { type = string, default = null }
variable "allowed_source_sg_ids" { type = list(string), default = [] }

# Health / platform / deploy
variable "health_path"                 { type = string, default = "/health" }
variable "health_check_grace_period"   { type = number, default = 60 }
variable "enable_execute_command"      { type = bool,   default = true }
variable "platform_version"            { type = string, default = "1.4.0" }
variable "deployment_min_healthy_percent" { type = number, default = 50 }
variable "deployment_max_percent"         { type = number, default = 200 }

# Capacity providers (optional per-service override)
variable "capacity_provider_strategy" {
  description = "If empty, uses launch_type=FARGATE"
  type = list(object({
    capacity_provider = string
    base              = optional(number, 0)
    weight            = optional(number, 1)
  }))
  default = []
}

# --- Host-based routing on :443 ---
variable "https_listener_arn" {
  description = "ARN of shared HTTPS :443 listener (from ingress). Required if expose_via_alb = true."
  type        = string
  default     = null
}

variable "hostnames" {
  description = "FQDNs that should route to this service (e.g., [\"users.dev.ecolors.app\"])."
  type        = list(string)
  default     = []
}

variable "listener_rule_priority" {
  description = "Unique priority for the rule on :443. Required if expose_via_alb = true."
  type        = number
  default     = null
}

# Optional: per-service DNS creation
variable "create_dns_records" {
  description = "Create Route53 A/ALIAS for hostnames → ALB"
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID containing the hostnames"
  type        = string
  default     = null
}

variable "alb_dns_name" {
  description = "ALB DNS name (alias target)"
  type        = string
  default     = null
}

variable "alb_zone_id" {
  description = "ALB zone ID (alias hosted zone ID)"
  type        = string
  default     = null
}
