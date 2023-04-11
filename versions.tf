terraform {
  required_version = ">= 1.2"

  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    google = {
      source  = "hashicorp/google"
      version = ">= 4.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.19"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 15.10.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}

