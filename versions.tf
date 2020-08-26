
terraform {
  required_version = ">= 0.13"
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}
