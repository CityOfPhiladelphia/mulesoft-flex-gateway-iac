variable "env_name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "dev_mode" {
  type        = bool
  description = "Enable to disable any type of deletion protection"
}

variable "flex_gateway_version" {
  type = string
}

# VPC
variable "vpc_id" {
  type = string
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "asg_subnet_ids" {
  type = list(string)
}

variable "redis_subnet_ids" {
  type = list(string)
}

variable "acm_cert_arn" {
  type = string
}

# Elasticache
variable "redis_instance_type" {
  type = string
}

variable "redis_engine_version" {
  type = string
}

variable "redis_num_cache_clusters" {
  type = number
}

# EC2
variable "ec2_instance_type" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "ssh_sg_id" {
  type = string
}

variable "ec2_ami_id" {
  type = string
}

variable "build_branch" {
  type        = string
  default     = "main"
  description = "What git branch to checkout before running the build script. Defaults to `main`."
}
# Secrets
variable "registration_keeper_id" {
  type = string
}

## Provisioner

