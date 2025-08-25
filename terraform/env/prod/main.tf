terraform {
  required_version = "~> 1.12"

  cloud {
    organization = "Philadelphia"

    workspaces {
      name = "mulesoft-flex-gateway-prod"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    secretsmanager = {
      source  = "keeper-security/secretsmanager"
      version = ">= 1.1.5"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "secretsmanager" {
}

module "flex_gateway" {
  source = "../../modules/flex_gateway"

  env_name = "prod"
  app_name = "flex-gateway"
  dev_mode = true
  # *.phila.gov
  acm_cert_arn = "arn:aws:acm:us-east-1:975050025792:certificate/dc0c25c0-84e6-45aa-90b5-590f8bd8296c"
  # Prod vpc
  vpc_id = "vpc-047bfd23682f9582f"
  # Prod subnet public zone A then B
  alb_subnet_ids = ["subnet-0b038e6e153e076a1", "subnet-010e02eaa1bf4ad02"]
  # Prod subnet private zone A then B
  asg_subnet_ids   = ["subnet-0d0d5a4bdbaf916d1", "subnet-00eb4cfd73abefd2e"]
  redis_subnet_ids = ["subnet-0d0d5a4bdbaf916d1", "subnet-00eb4cfd73abefd2e"]
  # Redis
  redis_engine_version     = "8.1"
  redis_instance_type      = "cache.t4g.small"
  redis_num_cache_clusters = 2
  # EC2
  ec2_instance_type = "t3.small"
  ssh_key_name      = "dev-key"
  build_branch      = "main"
  # prod remote SG
  ssh_sg_id = "sg-0ef9b74fa74804bcb"
  # Shared GSG -> Flex-Gateway -> Prod-Registration
  registration_keeper_id = "ODPsB00UvJmvHh4v5SEAtQ"
}
