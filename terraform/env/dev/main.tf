terraform {
  required_version = "~> 1.12"

  cloud {
    organization = "Philadelphia"

    workspaces {
      name = "mulesoft-flex-gateway-dev"
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

  env_name = "dev"
  app_name = "flex-gateway"
  dev_mode = true
  # *.phila.gov
  acm_cert_arn = "arn:aws:acm:us-east-1:975050025792:certificate/dc0c25c0-84e6-45aa-90b5-590f8bd8296c"
  # Non-prod vpc
  vpc_id = "vpc-0003c2fc508cbdab4"
  # Non-prod subnet public zone A then B
  alb_subnet_ids = ["subnet-021a798c801a6de15", "subnet-04befa32beadb1606"]
  # Non-prod subnet private zone A then B
  asg_subnet_ids   = ["subnet-0ff7f0642b438fbeb", "subnet-0d5478758a826841e"]
  redis_subnet_ids = ["subnet-0ff7f0642b438fbeb", "subnet-0d5478758a826841e"]
  # Redis
  redis_engine_version     = "8.1"
  redis_instance_type      = "cache.t4g.micro"
  redis_num_cache_clusters = 2
  # EC2
  ec2_instance_type = "t3.small"
  ssh_key_name      = "dev-key"
  build_branch      = "main"
  # non-prod remote SG
  ssh_sg_id = "sg-0014e8d551f6d514b"
  # Shared GSG -> Flex-Gateway -> Dev-Registration
  registration_keeper_id = "Atnut-qOEErxdf83itZxFg"
}
