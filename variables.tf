# Already have:
variable "aws_region"     { type = string }
variable "aws_access_key" { type = string }   # (recommend using TFC env vars instead)
variable "aws_secret_key" { type = string }

variable "environment" { type = string } # dev, qa, prod
variable "name" { type = string } # auth-provider-web-api

variable "tags" {
  type = map(string)
  default = {}
}

# ECR/image overrides stay optional (you won't pass them for dev/prod)
variable "repository_url" { type = string, default = null }
variable "image"          { type = string, default = null }  # full URI override
variable "image_tag"      { type = string, default = null }  # default computed


# ✅ make these optional (we'll fill from remote_state if null)
variable "cluster_arn"  { 
  type = string
  default = null
}
variable "subnet_ids"   {
  type = list(string)
default = null
}
variable "vpc_id"       { 
  type = string
  default = null
}

variable "assign_public_ip" {
  type = bool
  default = true
}

# sizing / image / env (unchanged)
variable "cpu"         { type = number }
variable "memory"      { type = number }
variable "container_port" { type = number }
variable "desired_count"  {
  type = number
  default = 1
}
variable "image"          {
  type = string
  default = null
}
variable "repository_url" { 
  type = string
  default = null
}
variable "image_tag"      {
  type = string
  default = "latest"
}
variable "env"            {
  type = map(string)
  default = {}
}
variable "secrets" {
  type    = list(object({
    name = string
    valueFrom = string
  }))
  default = []
}

# IAM / logs / SG (unchanged)
variable "execution_role_arn"    {
  type = string
  default = null
}
variable "create_execution_role" {
  type = bool
  default = true
}
variable "task_role_arn"         {
  type = string
  default = null
}
variable "task_role_inline_policy_json" {
  type = string
  default = null
}
variable "log_retention_days"    {
  type = number
  default = 14
}
variable "expose_via_alb"        {
  type = bool
  default = true
}
variable "alb_security_group_id" {
  type = string
  default = null
}
variable "allowed_source_sg_ids" {
  type = list(string)
  default = []
}

# health / platform / deploy (unchanged)
variable "health_path" {
  type = string
  default = "/health"
}
variable "health_check_grace_period" {
  type = number
  default = 60
}
variable "enable_execute_command"    {
  type = bool
  default = true
}
variable "platform_version"          {
  type = string
  default = "1.4.0"
}
variable "deployment_min_healthy_percent" {
  type = number
  default = 50
}
variable "deployment_max_percent"         {
  type = number
  default = 200
}

# capacity providers (unchanged)
variable "capacity_provider_strategy" {
  type = list(object({
    capacity_provider = string
    base              = optional(number, 0)
    weight            = optional(number, 1)
  }))
  default = []
}

# --- Host-based routing on :443 (make optional and fill from remote_state)
variable "https_listener_arn"  {
  type = string
  default = null
}
variable "hostnames"           {
  type = list(string)
  default = []
}
variable "listener_rule_priority" {
  type = number
  default = null
}

# Optional per-service DNS (make optional fill from remote_state)
variable "create_dns_records" {
  type = bool
  default = true
}
variable "route53_zone_id"    {
  type = string
  default = null
}
variable "alb_dns_name"       {
  type = string
  default = null
}
variable "alb_zone_id"        {
  type = string
  default = null
}

# --- NEW: remote state wiring (same pattern you used in ingress)
variable "remote_state_org"        {
  type = string
  default = null
}
variable "remote_state_network_ws" {
  type = string
  default = null
}
variable "remote_state_alb_ws" {
  type = string
  default = null
}
variable "remote_state_cluster_ws" {
  type = string
  default = null
}
variable "remote_state_ecr_ws" {
  type = string,
  default = null
}

