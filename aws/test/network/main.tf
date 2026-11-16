# ─────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────
resource "aws_vpc" "webapp_01_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "webapp-01-vpc"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Internet Gateway
# ─────────────────────────────────────────────
resource "aws_internet_gateway" "webapp_01_igw" {
  vpc_id = aws_vpc.webapp_01_vpc.id

  tags = {
    Name  = "webapp-01-igw"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Public Subnet
# ─────────────────────────────────────────────
resource "aws_subnet" "webapp_01_public_subnet" {
  vpc_id                  = aws_vpc.webapp_01_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "webapp-01-public-subnet"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Public Route Table (default route → IGW)
# ─────────────────────────────────────────────
resource "aws_route_table" "webapp_01_public_rt" {
  vpc_id = aws_vpc.webapp_01_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp_01_igw.id
  }

  tags = {
    Name  = "webapp-01-public-rt"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Route Table Association - public subnet
# ─────────────────────────────────────────────
resource "aws_route_table_association" "webapp_01_rt_association" {
  subnet_id      = aws_subnet.webapp_01_public_subnet.id
  route_table_id = aws_route_table.webapp_01_public_rt.id
}

# ─────────────────────────────────────────────
# Security Group (shell - rules managed below)
# ─────────────────────────────────────────────
resource "aws_security_group" "webapp_01_sg" {
  name        = "webapp-01-sg"
  description = "Security group for webapp-01: SSH and HTTP 8080 inbound, all outbound"
  vpc_id      = aws_vpc.webapp_01_vpc.id

  tags = {
    Name  = "webapp-01-sg"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Ingress rule - SSH TCP/22
# ─────────────────────────────────────────────
resource "aws_vpc_security_group_ingress_rule" "webapp_01_sg_ssh" {
  security_group_id = aws_security_group.webapp_01_sg.id
  description       = "Allow SSH inbound from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"

  tags = {
    Name  = "webapp-01-sg-ssh-inbound"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Ingress rule - HTTP TCP/8080
# ─────────────────────────────────────────────
resource "aws_vpc_security_group_ingress_rule" "webapp_01_sg_http" {
  security_group_id = aws_security_group.webapp_01_sg.id
  description       = "Allow HTTP 8080 inbound from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"

  tags = {
    Name  = "webapp-01-sg-http-inbound"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Egress rule - all traffic allowed
# ─────────────────────────────────────────────
resource "aws_vpc_security_group_egress_rule" "webapp_01_sg_egress" {
  security_group_id = aws_security_group.webapp_01_sg.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name  = "webapp-01-sg-egress-all"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Outputs - consumed by the compute stack via
# data sources (aws_vpc / aws_subnet /
# aws_security_group lookups by Name tag)
# ─────────────────────────────────────────────
output "vpc_id" {
  description = "ID of webapp-01-vpc"
  value       = aws_vpc.webapp_01_vpc.id
}

output "public_subnet_id" {
  description = "ID of webapp-01-public-subnet"
  value       = aws_subnet.webapp_01_public_subnet.id
}

output "internet_gateway_id" {
  description = "ID of webapp-01-igw"
  value       = aws_internet_gateway.webapp_01_igw.id
}

output "route_table_id" {
  description = "ID of webapp-01-public-rt"
  value       = aws_route_table.webapp_01_public_rt.id
}

output "security_group_id" {
  description = "ID of webapp-01-sg"
  value       = aws_security_group.webapp_01_sg.id
}