terraform {
  required_version = "~> 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.22.1"
    }
  }

  cloud {
    organization = "Philadelphia"

    workspaces {
      name = "mulesoft-flex-gateway-common"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
