variable "aws_region"        { type = string }
variable "aws_access_key"    { type = string }
variable "aws_secret_key"    { type = string }
variable "env"               { type = string }

variable "name" {
  description = "Service name (short, used in resource names)."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

variable "cluster_arn" {
  description = "ARN of the existing ECS cluster to attach to."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets where tasks run (awsvpc)."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID (required to create target groups when exposing via ALB)."
  type        = string
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks (true for public subnets)."
  type        = bool
  default     = true
}

variable "cpu" {
  description = "Task CPU units (e.g., 256, 512)."
  type        = number
}

variable "memory" {
  description = "Task memory (MiB)."
  type        = number
}

variable "container_port" {
  description = "Container port the app listens on."
  type        = number
}

variable "desired_count" {
  description = "Desired number of tasks."
  type        = number
  default     = 1
}

# Image configuration
variable "image" {
  description = "Full image URI (takes precedence)."
  type        = string
  default     = null
}

variable "repository_url" {
  description = "ECR repository URL (if image not provided)."
  type        = string
  default     = null
}

variable "image_tag" {
  description = "Image tag (used with repository_url)."
  type        = string
  default     = "latest"
}

# Env & Secrets
variable "env" {
  description = "Environment variables for the container."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "List of secrets for the container (name/valueFrom ARN)."
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# IAM roles (execution + task role)
variable "execution_role_arn" {
  description = "Use an existing Execution Role ARN. If null, module creates one."
  type        = string
  default     = null
}

variable "create_execution_role" {
  description = "Create Execution Role if not provided."
  type        = bool
  default     = true
}

variable "task_role_arn" {
  description = "Use an existing Task Role ARN. If null, module creates one."
  type        = string
  default     = null
}

variable "task_role_inline_policy_json" {
  description = "Optional inline policy JSON to attach to created Task Role."
  type        = string
  default     = null
}

# Logs
variable "log_retention_days" {
  description = "CloudWatch logs retention in days."
  type        = number
  default     = 14
}

# Exposure via ALB (per-port model)
variable "expose_via_alb" {
  description = "Whether to expose service via ALB listener+target group."
  type        = bool
  default     = true
}

variable "alb_arn" {
  description = "ARN of existing ALB (required if expose_via_alb)."
  type        = string
  default     = null
}

variable "alb_security_group_id" {
  description = "Security Group ID of the ALB (for SG ingress)."
  type        = string
  default     = null
}

variable "listener_port" {
  description = "Public listener port on ALB (per-service port)."
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "ALB listener protocol for this port (HTTP or HTTPS)."
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.listener_protocol)
    error_message = "listener_protocol must be HTTP or HTTPS"
  }
}

variable "certificate_arn" {
  description = "ACM certificate ARN (required if listener_protocol = HTTPS)."
  type        = string
  default     = null
}

variable "redirect_http_to_https" {
  description = "If true and protocol HTTPS, also create HTTP listener on same port that redirects to HTTPS."
  type        = bool
  default     = false
}

# Internal access (when not exposed via ALB)
variable "allowed_source_sg_ids" {
  description = "Security Group IDs allowed to reach the service (only used when not using ALB)."
  type        = list(string)
  default     = []
}

# Health check for target group
variable "health_path" {
  description = "HTTP health check path."
  type        = string
  default     = "/health"
}

variable "health_check_grace_period" {
  description = "Grace period (seconds) for service health checks."
  type        = number
  default     = 60
}

# Exec & platform
variable "enable_execute_command" {
  description = "Enable ECS Exec on the service."
  type        = bool
  default     = true
}

variable "platform_version" {
  description = "Fargate platform version."
  type        = string
  default     = "1.4.0"
}

# Capacity providers (optional per-service override)
variable "capacity_provider_strategy" {
  description = "Per-service capacity provider strategy. If empty, uses launch_type = FARGATE."
  type = list(object({
    capacity_provider = string
    base              = optional(number, 0)
    weight            = optional(number, 1)
  }))
  default = []
}

# Deployment tuning
variable "deployment_min_healthy_percent" { type = number, default = 50 }
variable "deployment_max_percent"        { type = number, default = 200 }

