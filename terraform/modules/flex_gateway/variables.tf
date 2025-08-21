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

variable "acm_cert_arn" {
  type = string
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

# Secrets
variable "registration_keeper_id" {
  type = string
}

## Provisioner

