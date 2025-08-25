resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.app_name}-${var.env_name}"
  subnet_ids = var.redis_subnet_ids

  tags = local.default_tags
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.app_name}-${var.env_name}"
  description                = "${var.app_name}-${var.env_name}"
  cluster_mode               = "disabled"
  engine                     = "valkey"
  engine_version             = var.redis_engine_version
  node_type                  = var.redis_instance_type
  kms_key_id                 = data.aws_ssm_parameter.kms_arn.value
  num_cache_clusters         = var.redis_num_cache_clusters
  automatic_failover_enabled = var.redis_num_cache_clusters >= 2
  multi_az_enabled           = var.redis_num_cache_clusters >= 2
  security_group_ids         = [aws_security_group.redis.id]
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  parameter_group_name       = "default.valkey8"
  auth_token                 = data.secretsmanager_login.redis.password
  auth_token_update_strategy = "ROTATE"
  transit_encryption_enabled = true
  transit_encryption_mode    = "required"
  apply_immediately          = true

  tags = local.default_tags
}
