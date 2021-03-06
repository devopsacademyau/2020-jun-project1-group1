# VPC
# New VPC with a /16 CIDR
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpcCIDR
  instance_tenancy     = var.instanceTenancy[0]
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "${var.project-name}-vpc"
  }
}


data "aws_availability_zones" "available" {
  state = "available"
}


# Subnets
# 2 /24 public subnets(different AZs)
# 2 /24 private subnets(different AZs)


resource "aws_subnet" "subnet-public-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpcCIDR, 8, 0)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = var.map_public_ip1
  tags = {
    Name = "${var.project-name}-subnet-public-1"
    Tier = "public"
  }
}

resource "aws_subnet" "subnet-private-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpcCIDR, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.project-name}-subnet-private-1"
    Tier = "private"
  }
}

resource "aws_subnet" "subnet-public-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpcCIDR, 8, 2)
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = var.map_public_ip2
  tags = {
    Name = "${var.project-name}-subnet-public-2"
    Tier = "public"
  }
}

resource "aws_subnet" "subnet-private-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpcCIDR, 8, 3)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.project-name}-subnet-private-2"
    Tier = "private"
  }
}




# Internet Gateway
# Internet Gateway in place
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project-name}-IGW"
  }
}



# Elastic IP for NAT Gateway
resource "aws_eip" "NAT-EIP" {
  vpc = true
}



# NAT Gateway
resource "aws_nat_gateway" "NAT-GW" {
  count = var.deploy_nat ? 1 : 0

  allocation_id = aws_eip.NAT-EIP.id
  subnet_id     = aws_subnet.subnet-public-1.id
  depends_on    = [aws_internet_gateway.IGW]
  tags = {
    Name = "${var.project-name}-NAT-GW"
  }
}

