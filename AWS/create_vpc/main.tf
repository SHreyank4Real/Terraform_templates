#https://network00.com/NetworkTools/IPv4SubnetCreator/
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags = {
        Name        = "VPC-1"
        Environment = var.environment
    }
}

#subnets
resource "aws_subnet" "public_subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
        Name        = "pub-sub-1a"
        Environment = var.environment
  }
}
resource "aws_subnet" "public_subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
        Name        = "pub-sub-1b"
        Environment = var.environment
  }
}
resource "aws_subnet" "public_subnet-3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.32.0/20"
  availability_zone       = "ap-south-1c"
  map_public_ip_on_launch = true
  tags = {
        Name        = "pub-sub-1c"
        Environment = var.environment
  }
}
resource "aws_subnet" "private_subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.48.0/20"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false
  tags = {
        Name        = "pri-sub-1a"
        Environment = var.environment
  }
}
resource "aws_subnet" "private_subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.64.0/20"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false
  tags = {
        Name        = "pri-sub-1b"
        Environment = var.environment
  }
}

# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name        = "VPC1-igw"
        Environment = var.environment
    }
}

#EIP and NAT gateway
resource "aws_eip" "nat_eip" {
    vpc        = true
    depends_on = [aws_internet_gateway.ig]
}
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_subnet-1.id
    tags = {
        Name        = "nat"
        Environment = var.environment
    }
    depends_on = [
        aws_eip.nat_eip,
        aws_subnet.public_subnet-1
    ]
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }
    tags = {
        Name        = "public-rt"
        Environment = var.environment
    }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }
    tags = {
        Name        = "private-rt"
        Environment = var.environment
    }
}

resource "aws_route_table_association" "asso1" {
  subnet_id      = aws_subnet.private_subnet-1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "asso2" {
  subnet_id      = aws_subnet.private_subnet-2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "asso3" {
  subnet_id      = aws_subnet.public_subnet-1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "asso4" {
  subnet_id      = aws_subnet.public_subnet-2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "asso5" {
  subnet_id      = aws_subnet.public_subnet-3.id
  route_table_id = aws_route_table.public.id
}