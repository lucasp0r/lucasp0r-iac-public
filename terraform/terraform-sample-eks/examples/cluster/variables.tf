variable "cluster_name" {
  type    = string
  default = "eks-sample"
}

variable "aws_ebs_csi_driver" {
  type    = bool
  default = false
}
