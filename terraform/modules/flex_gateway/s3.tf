// S3 bucket for storing grafana logs and prometheus metrics
resource "aws_s3_bucket" "main" {
  bucket = "phl-citygeo-${var.app_name}-${var.env_name}"

  tags = local.default_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_ssm_parameter.kms_id.value
    }

    bucket_key_enabled = true
  }
}


resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload registration
resource "aws_s3_object" "registration" {
  bucket         = aws_s3_bucket.main.bucket
  key            = "registration.yaml"
  content_base64 = data.secretsmanager_file.registration.file_ref[0].content_base64
}
