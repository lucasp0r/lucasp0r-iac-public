terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_instance" "ec2-associate" {
    ami = "ami-01cc34ab2709337aa"
    instance_type = "t2.micro"

    tags = {
        Name = "ec2-associate"
        department = "study"
    }
}