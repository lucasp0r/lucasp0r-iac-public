
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

variable "elb_names" {
    type =  list
    default = ["ec2-dev","ec2-stg","ec2-prd","ec2-sandbox"]

}

resource "aws_iam_user" "lb" {
    name = var.elb_names[count.index]
    count = 4
    path = "/system/"

} 

#count and count index uses.