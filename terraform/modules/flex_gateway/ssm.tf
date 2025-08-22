resource "aws_ssm_parameter" "s3_name" {
  name  = "/${var.app_name}/${var.env_name}/s3_name"
  value = aws_s3_bucket.main.bucket
  type  = "String"
}

resource "aws_ssm_parameter" "registration_s3_key" {
  name  = "/${var.app_name}/${var.env_name}/registration_s3_key"
  value = aws_s3_object.registration.key
  type  = "String"
}

resource "aws_ssm_parameter" "loki_pw" {
  name   = "/${var.app_name}/${var.env_name}/loki_pw"
  value  = data.secretsmanager_login.loki_basic.password
  type   = "SecureString"
  key_id = data.aws_ssm_parameter.kms_id.value
}

resource "aws_ssm_parameter" "loki_user" {
  name   = "/${var.app_name}/${var.env_name}/loki_user"
  value  = data.secretsmanager_login.loki_basic.login
  type   = "SecureString"
  key_id = data.aws_ssm_parameter.kms_id.value
}

resource "aws_ssm_parameter" "prometheus_pw" {
  name   = "/${var.app_name}/${var.env_name}/prometheus_pw"
  value  = data.secretsmanager_login.prometheus_basic.password
  type   = "SecureString"
  key_id = data.aws_ssm_parameter.kms_id.value
}

resource "aws_ssm_parameter" "prometheus_user" {
  name   = "/${var.app_name}/${var.env_name}/prometheus_user"
  value  = data.secretsmanager_login.prometheus_basic.login
  type   = "SecureString"
  key_id = data.aws_ssm_parameter.kms_id.value
}
