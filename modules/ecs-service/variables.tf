variable "aws_region"        { type = string }
variable "env"               { type = string }
variable "service_name"      { type = string }
variable "family"            { type = string } # stable "<env>-<service>"

variable "ecs_cluster_arn"   { type = string }
variable "subnet_ids"        { type = list(string) }
variable "security_group_ids"{ type = list(string) }

variable "cpu"               { type = number }
variable "memory"            { type = number }
variable "desired_count"     { type = number }

# Bootstrap (first run only)
variable "bootstrap"         {
  type = bool
  default = false
}
variable "ecr_repo_name"     { type = string }
variable "initial_image_tag" {
  type = string
  default = null
}
variable "container_port"    {
  type = number
  default = 8080
}

# Optional ALB exposure
variable "expose_via_alb"    {
  type = bool
  default = true
}
variable "alb_listener_arn"  {
  type = string
  default = null
}

variable "log_retention_days" {
  type = number
  default = 30
}

# NEW
variable "listener_port" { type = number }
variable "listener_protocol" { 
  type = string
  default = "HTTPS"
}
variable "alb_arn" { type = string }
variable "alb_security_group_id" { type = string }
variable "service_security_group_id" { type = string }
variable "certificate_arn" {
  type = string
  default = null
}
variable "environment" {
  description = "List of environment variables for the container"
  type = list(object({ name = string, value = string }))
  default = []
}
