# Ubuntu 20.04 LTS - intentionally outdated (1+ year old)
data "aws_ami" "ubuntu_2004" {
  most_recent = false
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20220901"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# INTENTIONAL WEAKNESS: SSH open to the entire internet
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for MongoDB EC2 instance"
  vpc_id      = aws_vpc.main.id

  # INTENTIONAL WEAKNESS: SSH exposed to public internet
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB accessible from EKS private subnets only
  ingress {
    description = "MongoDB from EKS private subnets"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

resource "aws_instance" "mongodb" {
  ami                    = data.aws_ami.ubuntu_2004.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.ssh_key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("${path.module}/userdata.sh", {
    mongodb_username = var.mongodb_username
    mongodb_password = var.mongodb_password
    s3_bucket        = aws_s3_bucket.mongodb_backups.bucket
    aws_region       = var.aws_region
  })

  tags = {
    Name = "${var.project_name}-mongodb"
  }
}
