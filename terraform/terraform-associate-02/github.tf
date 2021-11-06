terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "github" {
  token = ""

}

resource "github_repository" "terraform-repo" {
  name        = "terraform-repo"
  visibility = "private"

}
