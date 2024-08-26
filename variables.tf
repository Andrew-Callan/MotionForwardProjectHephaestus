variable "credential_file" {
  default = "/home/ec2-user/.aws/credentials"
}

variable "owner" {}
variable "project" {}
variable "vendor" {}

variable "region" {
  default = "us-east-1"
}

variable "VictimVpcCidr" {}
variable "VictimVpcName" {}
variable "AttackerVpcCidr" {}
variable "AttackerVpcName" {}
variable "VictimPublic1Cidr" {}
variable "VictimPrivate1Cidr" {}
variable "AttackerPublic1Cidr" {}