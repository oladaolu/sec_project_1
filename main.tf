provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.ubuntu.id // Replace with the Ubuntu 18.04 LTS AMI ID for your region
  instance_type = "t2.large"
  user_data = file("${path.module}/app_install.sh")
  key_name  = "security_compass_key"
  tags = {
    Name = "MicroK8s-SonarQube-Instance"
  }
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "instance_sg" {
  name_prefix = "Instance-SG-"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "ec2_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
