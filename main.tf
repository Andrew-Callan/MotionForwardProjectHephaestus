
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

### Creation of attacker, security, and victim VPCs ###

resource "aws_vpc" "Victim-VPC" {
  cidr_block = "${var.VictimVpcCidr}"

  tags = {
    Name    = "${var.VictimVpcName}"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

resource "aws_vpc" "Security-VPC" {
  cidr_block = "${var.SecurityVpcCidr}"

  tags = {
    Name    = "${var.SecurityVpcName}"
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


resource "aws_subnet" "SecurityPublic1" {
  vpc_id            = "${aws_vpc.Security-VPC.id}"
  cidr_block        = "${var.SecurityPublic1Cidr}"
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

resource "aws_internet_gateway" "SecurityIgw" {
  vpc_id = "${aws_vpc.Security-VPC.id}"

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

resource "aws_route_table" "SecurityPublicRouteTable" {
  vpc_id = "${aws_vpc.Security-VPC.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.SecurityIgw.id}"
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

resource "aws_route_table_association" "SecurityPublicRTA" {
  subnet_id      = "${aws_subnet.SecurityPublic1.id}"
  route_table_id = "${aws_route_table.SecurityPublicRouteTable.id}"
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

resource "aws_security_group" "SecurityAllowAll" {
  name        = "allow_all"
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.Security-VPC.id
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
  associate_public_ip_address = true
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
    Name    = "${var.owner}-AttackerMachine"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

### Security Device ENI Creation ###


resource "aws_network_interface" "SecurityEni_a" {
  subnet_id       = aws_subnet.SecurityPublic1.id
  security_groups  = [aws_security_group.SecurityAllowAll.id]
}
resource "aws_eip" "SecurityDevicePublicEIP" {
  domain                    = "vpc"
  depends_on = [
    aws_network_interface.SecurityEni_a
  ]
  network_interface         = "${aws_network_interface.SecurityEni_a.id}"
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
  tags = {
    Name    = "${var.owner}-SecurityMachine"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

#################################################################
/*
DEPRACATED - Using Transit Gateway instead
### Networking Resources to Allow communication between Victim and Attacker VPCs ###

resource "aws_vpc_peering_connection" "AttackerVictimVPCPeering" {
  peer_vpc_id   = aws_vpc.Victim-VPC.id
  vpc_id        = aws_vpc.Attacker-VPC.id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between Attacker and Victim"
  }
}

resource "aws_route" "VictimPublicToAttackerRoute" {
  route_table_id         = aws_route_table.VictimPublicRouteTable.id
  destination_cidr_block = aws_vpc.Attacker-VPC.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.AttackerVictimVPCPeering.id
}
resource "aws_route" "VictimPrivateToAttackerRoute" {
  route_table_id         = aws_route_table.VictimPrivateRouteTable.id
  destination_cidr_block = aws_vpc.Attacker-VPC.cidr_block
  network_interface_id = aws_network_interface.SecurityEni_b.id
}


resource "aws_route" "AttackerToVictimRoute" {
  route_table_id         = aws_route_table.AttackerPublicRouteTable.id
  destination_cidr_block = aws_vpc.Victim-VPC.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.AttackerVictimVPCPeering.id
}
*/
#################################################################

# TRANSIT GATEWAY AND ROUTES CREATION

#Create gateway
resource "aws_ec2_transit_gateway" "HephTransitGateway" {
      tags = {
    Name = "VPC Peering between Attacker and Victim through security VPC"
    Owner   = "${var.owner}"
    Project = "${var.project}"
  }
}

# Create Transit Gateway VPC Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "VictimVPC_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.HephTransitGateway.id
  vpc_id = aws_vpc.Victim-VPC.id
  subnet_ids = [aws_subnet.VictimPublic1.id]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "AttackerVPC_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.HephTransitGateway.id
  vpc_id = aws_vpc.Attacker-VPC.id
  subnet_ids = [aws_subnet.AttackerPublic1.id]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "SecurityVPC_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.HephTransitGateway.id
  vpc_id = aws_vpc.Security-VPC.id
  subnet_ids = [aws_subnet.SecurityPublic1.id]
}

# Create Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "tgw_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.HephTransitGateway.id
}

# Associate route table with Transit Gateway Attachments
resource "aws_ec2_transit_gateway_route_table_association" "VictimVPC_association" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.VictimVPC_attachment.id
}

resource "aws_ec2_transit_gateway_route_table_association" "AttackerVPC_association" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.AttackerVPC_attachment.id
}

resource "aws_ec2_transit_gateway_route_table_association" "SecurityVPC_association" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.SecurityVPC_attachment.id
}

# Define routes in the Transit Gateway Route Table to route traffic through Security VPC
resource "aws_ec2_transit_gateway_route" "route_from_victimvpc" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
  destination_cidr_block = "192.168.128.0/17"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.SecurityVPC_attachment.id
}

resource "aws_ec2_transit_gateway_route" "route_from_attackervpc" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
  destination_cidr_block = "192.168.0.0/17"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.SecurityVPC_attachment.id
}

# Add routes in each VPC's route table to direct traffic to the Transit Gateway

resource "aws_route" "VictimVPC_to_tgw" {
  route_table_id = aws_route_table.VictimPublicRouteTable.id
  destination_cidr_block = "192.168.128.0/17"
  transit_gateway_id = aws_ec2_transit_gateway.HephTransitGateway.id
}

resource "aws_route" "AttackerVPC_to_tgw" {
  route_table_id = aws_route_table.AttackerPublicRouteTable.id
  destination_cidr_block = "192.168.0.0/17"
  transit_gateway_id = aws_ec2_transit_gateway.HephTransitGateway.id
}

resource "aws_route" "SecurityVPC_to_tgw" {
  route_table_id = aws_route_table.SecurityPublicRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  #transit_gateway_id = aws_ec2_transit_gateway.HephTransitGateway.id
  network_interface_id = aws_network_interface.SecurityEni_a.id
}

