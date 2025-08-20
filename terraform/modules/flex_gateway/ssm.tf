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
