provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.credential_file}"
}

##Creation of attacker and victim VPCs

resource "aws_vpc" "Victim-VPC" {
  cidr_block = "${var.VictimVpcCidr}"

  tags {
    Name    = "${var.VictimvpcName}"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

resource "aws_vpc" "Attacker-VPC" {
  cidr_block = "${var.AttackerVpcCidr}"

  tags {
    Name    = "${var.AttackervpcName}"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

### Subnet Creation ###

resource "aws_subnet" "VictimPublic1" {
  vpc_id            = "${aws_vpc.Victim-VPC.id}"
  cidr_block        = "${var.VictimPublic1Cidr}"

  tags {
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}


resource "aws_subnet" "VictimPrivate1" {
  vpc_id     = "${aws_vpc.Victim-VPC.id}"
  cidr_block = "${var.VictimPrivate1Cidr}"

  tags {
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}


resource "aws_subnet" "AttackerPublic1" {
  vpc_id            = "${aws_vpc.Attacker-VPC.id}"
  cidr_block        = "${var.AttackerPublic1Cidr}"

  tags {
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}


resource "aws_subnet" "Attackerprivate1" {
  vpc_id     = "${aws_vpc.Attacker-VPC.id}"
  cidr_block = "${var.VAttackerPrivate1Cidr}"

  tags {
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}