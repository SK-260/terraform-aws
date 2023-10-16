# Create the VPC
resource "aws_vpc" "VPC" {
  cidr_block       = var.vpc-cidr
  instance_tenancy = "default"

  tags = {
    Name = "VPC"
  }
}

# Create the public subnet
resource "aws_subnet" "publicsub-1" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.public-subnet[0]
  availability_zone = var.availability_zone[0]

  tags = {
    name = "publicsub-1"
  }
}

resource "aws_subnet" "publicsub-2" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.public-subnet[1]
  availability_zone       = var.availability_zone[1]
  map_public_ip_on_launch = true

  tags = {
    name = "publicsub-2"
  }
}

# Create Private subnets
resource "aws_subnet" "privatesub-1" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.private-subnet[0]
  availability_zone       = var.availability_zone[0]
  map_public_ip_on_launch = false

  tags = {
    name = "privatesub-1"
  }
}

resource "aws_subnet" "privatesub-2" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.private-subnet[1]
  availability_zone       = var.availability_zone[1]
  map_public_ip_on_launch = false

  tags = {
    name = "privatesub-2"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "Internet Gateway"
  }
}

# Create Route Tabel for the internet Gateway
resource "aws_route_table" "project-routetable" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "project-routetable"
  }
}

# Connect Public subnets to the route Table
resource "aws_route_table_association" "public-route-1" {
  subnet_id      = aws_subnet.publicsub-1.id
  route_table_id = aws_route_table.project-routetable.id
}

resource "aws_route_table_association" "public-route-2" {
  subnet_id      = aws_subnet.publicsub-2.id
  route_table_id = aws_route_table.project-routetable.id
}

# Create Security groups
resource "aws_security_group" "public-sg" {
  name        = "public-sg"
  description = "Allow web and ssh traffic"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private-sg" {
  name        = "private-sg"
  description = "Allow web tier and ssh access"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
    security_groups = [aws_security_group.public-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Security group for alb"
  vpc_id      = aws_vpc.VPC.id

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
}