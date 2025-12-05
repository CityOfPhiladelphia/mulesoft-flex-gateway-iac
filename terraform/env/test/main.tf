terraform {
  required_version = "~> 1.12"

  backend "s3" {
    bucket = "phl-citygeo-terraform-state"
    # CHANGE ME!
    key          = "flex-gateway/test"
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

  env_name = "test"
  app_name = "flex-gateway"
  dev_mode = true
  # renovate: datasource=docker depName=mulesoft/flex-gateway
  flex_gateway_tag = "1.10.3"
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
  redis_num_cache_clusters = 1
  # EC2
  ec2_instance_type = "t3.small"
  ssh_key_name      = "dev-key"
  # Note: AMI is hardcoded to Kernel 6.12. Make note to occasionally update that manually
  # amiFilter=[{"Name":"owner-id","Values":["137112412989"]},{"Name":"name","Values":["al2023-ami-2023*-kernel-6.12-x86_64"]},{"Name":"architecture","Values":["x86_64"]},{"Name":"virtualization-type","Values":["hvm"]}]
  # currentImageName=al2023-ami-2023.9.20251117.1-kernel-6.12-x86_64
  ec2_ami_id   = "ami-0f00d706c4a80fd93"
  build_branch = "main"
  # non-prod remote SG
  ssh_sg_id = "sg-0014e8d551f6d514b"
  # Shared GSG -> Flex-Gateway -> Test-Registration
  registration_keeper_id = "lv4qSA1x9r_hBnPhx-HX_A"
}
