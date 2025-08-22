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

data "secretsmanager_file" "registration" {
  path = var.registration_keeper_id
}

// Shared-GSG -> Grafana -> Loki -> BasicAuth
data "secretsmanager_login" "loki_basic" {
  path = "TVNsnRso_U7J_raing91Dw"
}

// Shared-GSG -> Grafana -> Prometheus -> BasicAuth
data "secretsmanager_login" "prometheus_basic" {
  path = "9edLxyQsbIoU5lw7K3m36w"
}
