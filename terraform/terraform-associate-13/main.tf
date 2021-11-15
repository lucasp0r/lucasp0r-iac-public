provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}


data "aws_ami" "app_ami" {
    most_recent = true
    owners = ["amazon"]


    filter {
        name = "name"
        values = ["amazn2-ami-hvm*"]

    }
}

resource "aws_instance" "instance-1" {ldd
    ami = data.aws_ami.app_ami.id
    instance_type = "t2.micro"
}

