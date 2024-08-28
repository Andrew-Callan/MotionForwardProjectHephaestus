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

variable "VictimAmi" {}
variable "AttackerAmi" {}
variable "SecurityAmi" {}
variable "VictimInstanceType" {}
variable "AttackerInstanceType" {}
variable "SecurityInstanceType" {}
variable "VictimVolumeSize" {}
variable "AttackerVolumeSize" {}
variable "SecurityVolumeSize" {}
variable "VictimKeyName" {}
variable "AttackerKeyName" {}
variable "SecurityKeyName" {}