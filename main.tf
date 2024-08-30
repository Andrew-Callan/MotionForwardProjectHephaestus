
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                  = "${var.region}"
  shared_credentials_files = ["${var.credential_file}"]
  shared_config_files = ["${var.config_file}"]
  #profile = "default"
}

### Creation of attacker and victim VPCs ###

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
  availability_zone = "${var.region}a"

  tags = {
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}


resource "aws_subnet" "VictimPrivate1" {
  vpc_id     = "${aws_vpc.Victim-VPC.id}"
  cidr_block = "${var.VictimPrivate1Cidr}"
  availability_zone = "${var.region}a"

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

### Internet gateway creation ###

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
    gateway_id = "${aws_internet_gateway.AttackerIgw.id}"
  }
}

### Associating Subnets with Route Tables ###

resource "aws_route_table_association" "VictimPublicRTA" {
  subnet_id      = "${aws_subnet.VictimPublic1.id}"
  route_table_id = "${aws_route_table.VictimPublicRouteTable.id}"
}

resource "aws_route_table_association" "VictimPrivateRTA" {
  subnet_id      = "${aws_subnet.VictimPrivate1.id}"
  route_table_id = "${aws_route_table.VictimPrivateRouteTable.id}"
}

resource "aws_route_table_association" "AttackerPublicRTA" {
  subnet_id      = "${aws_subnet.AttackerPublic1.id}"
  route_table_id = "${aws_route_table.AttackerPublicRouteTable.id}"
}


### Security Group Creation ###

resource "aws_security_group" "AttackerAllowAll" {
  name        = "allow_all"
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.Attacker-VPC.id
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "${var.project}-AllowAll"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

resource "aws_security_group" "VictimAllowAll" {
  name        = "allow_all"
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.Victim-VPC.id
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "${var.project}-AllowAll"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

### EC2 Instance Creation ###

resource "aws_instance" "VictimMachine" {
  ami           = "${var.VictimAmi}"
  instance_type = "${var.VictimInstanceType}"

  key_name                    = "${var.VictimKeyName}"
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.VictimPrivate1.id}"
  vpc_security_group_ids      = ["${aws_security_group.VictimAllowAll.id}"]
  root_block_device {
    volume_size = "${var.VictimVolumeSize}"
    tags = {
        Name    = "${var.owner}-VictimRootDevice"
        Owner   = "${var.owner}"
        Project = "${var.project}"
    }
  }

  tags = {
    Name    = "${var.owner}-VictimMachine"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

resource "aws_instance" "AttackerMachine" {
  ami           = "${var.AttackerAmi}"
  instance_type = "${var.AttackerInstanceType}"

  key_name                    = "${var.AttackerKeyName}"
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.AttackerPublic1.id}"
  vpc_security_group_ids      = ["${aws_security_group.AttackerAllowAll.id}"]
  root_block_device {
    volume_size = "${var.AttackerVolumeSize}"
    tags = {
        Name    = "${var.owner}-AttackerRootDevice"
        Owner   = "${var.owner}"
        Project = "${var.project}"
    }
  }

  tags = {
    Name    = "${var.owner}-AttackermMachine"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

### Security Device ENI Creation ###




resource "aws_network_interface" "SecurityEni_a" {
  subnet_id       = aws_subnet.VictimPublic1.id
  security_groups  = [aws_security_group.VictimAllowAll.id]
}
resource "aws_eip" "SecurityDevicePublicEIP" {
  domain                    = "vpc"
  network_interface         = "${aws_network_interface.SecurityEni_a.id}"
}

resource "aws_network_interface" "SecurityEni_b" {
  subnet_id       = aws_subnet.VictimPrivate1.id
  security_groups  = [aws_security_group.VictimAllowAll.id]
}

### Security Device EC2 Instance ###

resource "aws_instance" "SecurityDevice" {
  ami           = "${var.SecurityAmi}"
  instance_type = "${var.SecurityInstanceType}"

  key_name                    = "${var.SecurityKeyName}"
  #associate_public_ip_address = true
  #subnet_id                   = "${aws_subnet.VictimPublic1.id}"
  #vpc_security_group_ids      = ["${aws_security_group.VictimAllowAll.id}"]
  root_block_device {
    volume_size = "${var.SecurityVolumeSize}"
    tags = {
        Name    = "${var.owner}-SecurityDevice"
        Owner   = "${var.owner}"
        Project = "${var.project}"
    }
  }
  network_interface {
    network_interface_id = aws_network_interface.SecurityEni_a.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.SecurityEni_b.id
    device_index         = 1
  }
  tags = {
    Name    = "${var.owner}-VictimMachine"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

### Networking Resources to Allow communication between Victim and Attacker VPCs ###

resource "aws_vpc_peering_connection" "AttackerVictimVPCPeering" {
  peer_vpc_id   = aws_vpc.Victim-VPC.id
  vpc_id        = aws_vpc.Attacker-VPC.id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between Attacker and Victim"
  }
}

resource "aws_route" "VictimToAttackerRoute" {
  route_table_id         = aws_route_table.VictimPublicRouteTable.id
  destination_cidr_block = aws_vpc.Attacker-VPC.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.AttackerVictimVPCPeering.id
}

resource "aws_route" "AttackerToVictimRoute" {
  route_table_id         = aws_route_table.AttackerPublicRouteTable.id
  destination_cidr_block = aws_vpc.Victim-VPC.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.AttackerVictimVPCPeering.id
}

/*
resource "aws_route" "RouteThroughSecurityDevice" {
  route_table_id         = aws_route_table.AttackerPublicRouteTable.id
  destination_cidr_block = "${var.VictimPrivate1Cidr}"
  network_interface_id = aws_network_interface.SecurityEni_a.id
}
*/