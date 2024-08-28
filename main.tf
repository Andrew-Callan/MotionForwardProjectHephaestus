provider "aws" {
  region                  = "${var.region}"
  shared_credentials_files = "${var.credential_file}"
}

##Creation of attacker and victim VPCs

resource "aws_vpc" "Victim-VPC" {
  cidr_block = "${var.VictimVpcCidr}"

  tags = {
    Name    = "${var.VictimVpcName}"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

resource "aws_vpc" "Attacker-VPC" {
  cidr_block = "${var.AttackerVpcCidr}"

  tags = {
    Name    = "${var.AttackerVpcName}"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

### Subnet Creation ###

resource "aws_subnet" "VictimPublic1" {
  vpc_id            = "${aws_vpc.Victim-VPC.id}"
  cidr_block        = "${var.VictimPublic1Cidr}"

  tags = {
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}


resource "aws_subnet" "VictimPrivate1" {
  vpc_id     = "${aws_vpc.Victim-VPC.id}"
  cidr_block = "${var.VictimPrivate1Cidr}"

  tags = {
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}


resource "aws_subnet" "AttackerPublic1" {
  vpc_id            = "${aws_vpc.Attacker-VPC.id}"
  cidr_block        = "${var.AttackerPublic1Cidr}"

  tags = {
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

## Internet gateway creation

resource "aws_internet_gateway" "VictimIgw" {
  vpc_id = "${aws_vpc.Victim-VPC.id}"

  tags = {
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

resource "aws_internet_gateway" "AttackerIgw" {
  vpc_id = "${aws_vpc.Attacker-VPC.id}"

  tags = {
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

### EIP and NatGW Creation ###

resource "aws_eip" "natgwEip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "VictimNatgw" {
  allocation_id = "${aws_eip.natgwEip.id}"
  subnet_id     = "${aws_subnet.VictimPrivate1.id}"

  tags = {
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}


### Creating Public and Private Subnet Route Tables ###

resource "aws_route_table" "VictimPublicRouteTable" {
  vpc_id = "${aws_vpc.Victim-VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.VictimIgw.id}"
  }
}

resource "aws_route_table" "VictimPrivateRouteTable" {
  vpc_id = "${aws_vpc.Victim-VPC.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.VictimNatgw.id}"
  }
}

resource "aws_route_table" "AttackerPublicRouteTable" {
  vpc_id = "${aws_vpc.Attacker-VPC.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_internet_gateway.AttackerIgw.id}"
  }
}

### Associating Subnets with Route Tables ###

resource "aws_route_table_association" "VictimPublicRTA" {
  subnet_id      = "${aws_subnet.VictimPublic1.id}"
  route_table_id = "${aws_route_table.VictimPrivateRouteTable.id}"
}

resource "aws_route_table_association" "VictimPrivateRTA" {
  subnet_id      = "${aws_subnet.VictimPrivate1.id}"
  route_table_id = "${aws_route_table.VictimPrivateRouteTable.id}"
}

resource "aws_route_table_association" "AttackerPublicRTA" {
  subnet_id      = "${aws_subnet.AttackerPublic1.id}"
  route_table_id = "${aws_route_table.AttackerPublicRouteTable.id}"
}
