resource "aws_vpc" "multi-dr-vpc-region1" {
  provider              = aws.region1
  cidr_block            = var.vpc_cidr_region1
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name = "multi-dr-vpc-region1"
  }
}

resource "aws_internet_gateway" "multi-dr-igw-region1" {
  provider = aws.region1
  vpc_id   = aws_vpc.multi-dr-vpc-region1.id
}

resource "aws_subnet" "multi-dr-subnet-region1a" {
  provider                = aws.region1
  vpc_id                  = aws_vpc.multi-dr-vpc-region1.id
  cidr_block              = var.public_subnets_region1[0]
  availability_zone       = var.azs_region1[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "multi-dr-subnet-region1a"
  }
}

resource "aws_subnet" "multi-dr-subnet-region1b" {
  provider                = aws.region1
  vpc_id                  = aws_vpc.multi-dr-vpc-region1.id
  cidr_block              = var.public_subnets_region1[1]
  availability_zone       = var.azs_region1[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "multi-dr-subnet-region1b"
  }
}

resource "aws_route_table" "multi-dr-rt-region1" {
  provider = aws.region1
  vpc_id   = aws_vpc.multi-dr-vpc-region1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.multi-dr-igw-region1.id
  }
}

resource "aws_route_table_association" "multi-dr-rta-region1a" {
  provider       = aws.region1
  subnet_id      = aws_subnet.multi-dr-subnet-region1a.id
  route_table_id = aws_route_table.multi-dr-rt-region1.id
}

resource "aws_route_table_association" "multi-dr-rta-region1b" {
  provider       = aws.region1
  subnet_id      = aws_subnet.multi-dr-subnet-region1b.id
  route_table_id = aws_route_table.multi-dr-rt-region1.id
}

resource "aws_vpc" "multi-dr-vpc-region2" {
  provider              = aws.region2
  cidr_block            = var.vpc_cidr_region2
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name = "multi-dr-vpc-region2"
  }
}

resource "aws_internet_gateway" "multi-dr-igw-region2" {
  provider = aws.region2
  vpc_id   = aws_vpc.multi-dr-vpc-region2.id
}

resource "aws_subnet" "multi-dr-subnet-region2a" {
  provider                = aws.region2
  vpc_id                  = aws_vpc.multi-dr-vpc-region2.id
  cidr_block              = var.public_subnets_region2[0]
  availability_zone       = var.azs_region2[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "multi-dr-subnet-region2a"
  }
}

resource "aws_subnet" "multi-dr-subnet-region2b" {
  provider                = aws.region2
  vpc_id                  = aws_vpc.multi-dr-vpc-region2.id
  cidr_block              = var.public_subnets_region2[1]
  availability_zone       = var.azs_region2[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "multi-dr-subnet-region2b"
  }
}

resource "aws_route_table" "multi-dr-rt-region2" {
  provider = aws.region2
  vpc_id   = aws_vpc.multi-dr-vpc-region2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.multi-dr-igw-region2.id
  }
}

resource "aws_route_table_association" "multi-dr-rta-region2a" {
  provider       = aws.region2
  subnet_id      = aws_subnet.multi-dr-subnet-region2a.id
  route_table_id = aws_route_table.multi-dr-rt-region2.id
}

resource "aws_route_table_association" "multi-dr-rta-region2b" {
  provider       = aws.region2
  subnet_id      = aws_subnet.multi-dr-subnet-region2b.id
  route_table_id = aws_route_table.multi-dr-rt-region2.id
}
