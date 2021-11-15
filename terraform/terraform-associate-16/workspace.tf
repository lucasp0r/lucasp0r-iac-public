provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2-associate" {
    ami = "ami-01cc34ab2709337aa"
    instance_type = lookup(var.instance_type,terraform.workspace)

    tags = {
        Name = "ec2-associate"
        department = "study"
    }
}

variable "instance_type" {
    type = "map"

    default = {
        default = "t2.nano"
        dev = "t2.micro"
        prd = "t2.large"
    }
}