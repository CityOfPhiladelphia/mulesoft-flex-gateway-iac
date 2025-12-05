terraform {
  required_version = "~> 1.12"

  backend "s3" {
    bucket = "phl-citygeo-terraform-state"
    # CHANGE ME!
    key          = "flex-gateway/prod"
    region       = "us-east-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
    secretsmanager = {
      source  = "keeper-security/secretsmanager"
      version = "1.1.7"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::975050025792:role/TFRole"
    session_name = "tf"
  }
}

provider "secretsmanager" {
}

module "flex_gateway" {
  source = "../../modules/flex_gateway"

  env_name = "prod"
  app_name = "flex-gateway"
  dev_mode = true
  # renovate: datasource=docker depName=mulesoft/flex-gateway
  flex_gateway_tag = "1.10.3"
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
  # Note: AMI is hardcoded to Kernel 6.12. Make note to occasionally update that manually
  # amiFilter=[{"Name":"owner-id","Values":["137112412989"]},{"Name":"name","Values":["al2023-ami-2023*-kernel-6.12-x86_64"]},{"Name":"architecture","Values":["x86_64"]},{"Name":"virtualization-type","Values":["hvm"]}]
  # currentImageName=al2023-ami-2023.9.20251027.0-kernel-6.12-x86_64
  ec2_ami_id   = "ami-080c353f4798a202f"
  build_branch = "main"
  # prod remote SG
  ssh_sg_id = "sg-0ef9b74fa74804bcb"
  # Shared GSG -> Flex-Gateway -> Prod-Registration
  registration_keeper_id = "ODPsB00UvJmvHh4v5SEAtQ"
}
