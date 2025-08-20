locals {
  default_tags = {
    ManagedBy   = "Terraform"
    Application = var.app_name
    TfEnv       = var.env_name
  }
}

data "aws_ssm_parameter" "kms_arn" {
  name = "/mulesoft/common/kms_arn"
}

data "aws_ssm_parameter" "kms_id" {
  name = "/mulesoft/common/kms_id"
}

// Shared-GSG -> Flex-Gateway -> rds
data "secretsmanager_file" "registration" {
  path = var.registration_keeper_id
}
