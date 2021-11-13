
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

#Condicional para que caso seja verdadeiro o test no caso o true está em ec2-dev, criará a ec2 de test.
# condition ? true_val : false_val, declare by variable
variable "istest"{

}

resource "aws_instance" "ec2-prd"{
    ami = "ami001cc34ab2709337aa"+ 
    instance_type = "t2.micro"
    count = var.istest == false ? 1 : 0
}


resource "aws_instance" "ec2-dev"{
    ami = "ami001cc34ab2709337aa"
    instance_type = "t2.micro"
    count = var.istest == true ? 1 : 0
}

