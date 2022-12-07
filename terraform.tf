terraform {
  cloud { #This workspace is configured to store state for local Terraform runs in the terraform cloud in below organizattion and workspace.
     organization = "terraformcloud-practice-1"
    workspaces {
      name = "local-terraform-circleci-workspace"
    }
  }

  required_providers { #Using aws provider version as 4.4.0
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4.0"
    }
  }

  required_version = ">= 1.2.0" #Using terraform version 1.2.0
}

