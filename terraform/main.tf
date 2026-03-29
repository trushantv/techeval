terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  # S3 backend for remote state - bucket must be created before terraform init
  # Do NOT commit terraform.tfstate to the repo
  backend "s3" {
    bucket  = "techeval-tf-state-bucket"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "helm" {
  kubernetes {
    host                   = try(aws_eks_cluster.main.endpoint, "")
    cluster_ca_certificate = try(base64decode(aws_eks_cluster.main.certificate_authority[0].data), "")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", try(aws_eks_cluster.main.name, "")]
      command     = "aws"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "Terraform"
    }
  }
}
