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

resource "aws_security_group" "allow_tls"{
    name = "allow_tls"
    description = "Allow TLS inbound traffic"

    ingress {
        from_port = 443
        to_port   = 443
        protocol  = "tcp"
        cidr_blocks = ["${aws_eip.lb.public_ip}/32"]

    }
}

output "allow_tls"{
    value = aws_eip.lb.public_ip
}


resource "aws_eip" "lb"{
    vpc = true
}

resource "aws_eip_association" "eip_assoc" {
    instance_id = "${aws_instance.ec2-associate.id}"
    allocation_id = "${aws_eip.lb.id}"

}

