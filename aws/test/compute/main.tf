# ─────────────────────────────────────────────────────────────────────────────
# DATA SOURCE: Latest Amazon Linux 2023 AMI (x86_64, HVM, EBS)
# ─────────────────────────────────────────────────────────────────────────────
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# DATA SOURCE: Existing key pair "ec2-key-pair"
# ─────────────────────────────────────────────────────────────────────────────
data "aws_key_pair" "ec2_key_pair_ref" {
  key_name = "ec2-key-pair"
}

# ─────────────────────────────────────────────────────────────────────────────
# DATA SOURCE: Look up the already-deployed public subnet (from 'network' stack)
# ─────────────────────────────────────────────────────────────────────────────
data "aws_subnet" "webapp_01_public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["webapp-01-public-subnet"]
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# DATA SOURCE: Look up the already-deployed security group (from 'network' stack)
# ─────────────────────────────────────────────────────────────────────────────
data "aws_security_group" "webapp_01_sg" {
  name = "webapp-01-sg"
}

# ─────────────────────────────────────────────────────────────────────────────
# EC2 INSTANCE: webapp-01
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_instance" "webapp_01_instance" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  availability_zone           = "ap-south-1a"
  subnet_id                   = data.aws_subnet.webapp_01_public_subnet.id
  vpc_security_group_ids      = [data.aws_security_group.webapp_01_sg.id]
  key_name                    = data.aws_key_pair.ec2_key_pair_ref.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Install Apache (httpd)
    dnf install -y httpd

    # Reconfigure Apache to listen on port 8080 instead of 80
    sed -i 's/^Listen 80$/Listen 8080/' /etc/httpd/conf/httpd.conf

    # Create the index page
    echo "Hello from Webapp 01" > /var/www/html/index.html

    # Enable and start httpd on boot
    systemctl enable httpd
    systemctl start httpd
  EOF

  user_data_replace_on_change = true

  tags = {
    Name  = "webapp-01"
    Stack = "compute"
  }
}