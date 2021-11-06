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


resource "aws_eip" "lb"{
    vpc = true
}

output "eip"{
    value = aws_eip.lb.public_ip
}


resource "aws_s3_bucket" "mys3"{
    bucket = "associate-terraform-exam-lucasp0r"
}

output "mys3bucket"{
    value = aws_s3_bucket.mys3.bucket_domain_name
}
