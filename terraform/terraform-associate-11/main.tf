
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

locals {
    common_tags = {
        Owner = "DevOps Team"
        service = "backend"
    }
}

resource "aws_instance" "app-dev"{
    ami = "ami-01cc34ab2709337aa"
    instance_type = "t2.micro"
    tags = local.common_tags
}

