variable "aws_region"        { type = string }
variable "aws_access_key"    { type = string }
variable "aws_secret_key"    { type = string }
variable "env"               { type = string }  # dev | prod | ...
variable "service_name"      { type = string }  # users | orders | email

# the external listener port for this service (e.g., 5000 or 5001)
variable "listener_port" {
  type        = number
  description = "External ALB port for this service."
}


# ---- Cluster remote-state hookup (points to clusters workspace) ----
variable "clusters_org"      { type = string }  # TFC org name
variable "clusters_ws_name"  { type = string }  # e.g., clusters-dev

# ---- Service sizing (Terraform controls cost here) ----
variable "cpu"               { type = number }  # e.g., 256/512/1024
variable "memory"            { type = number }  # MiB e.g., 512/1024/2048
variable "desired_count"     {
  type = number
  default = 1
}

# ---- Networking from cluster outputs (we’ll fetch via remote state) ----
# Nothing here; they come from terraform_remote_state (subnets, SG, ALB listener)

# ---- ALB routing (optional if headless/internal) ----
variable "expose_via_alb"    { 
  type = bool
  default = true 
}
variable "container_port"    {
  type = number
  default = 8080
}
variable "path_pattern"      {
  type = string
  default = "/"
}        # e.g., /users*, /orders*
variable "priority"          {
  type = number
  default = 100
}         # listener rule priority (unique)

# ---- Bootstrap (first run only) ----
# On first ever apply for a service, you must provide an initial image tag that exists.
# After first apply, set bootstrap=false and you won’t touch images with Terraform anymore.
variable "bootstrap"         {
  type = bool
  default = false
}
variable "ecr_repo_name"     {
  type = string
}                        # will be created if absent
variable "initial_image_tag" {
  type = string
  default = null
}        # e.g., dev-users-1.0.0
variable "environment" {
  description = "List of environment variables for the container"
  type = list(object({ name = string, value = string }))
  default = []
}
