provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "key" {
 algorithm = "RSA"
 rsa_bits  = 4096
}
 
resource "aws_key_pair" "aws_key" {
 key_name   = "sec-ssh-key"
 public_key = tls_private_key.key.public_key_openssh
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-0e7cbec6664f10896" // Replace with the Ubuntu 18.04 LTS AMI ID for your region
  instance_type = "t2.large"
  user_data = file("${path.module}/app_install.sh")
  key_name  = aws_key_pair.aws_key.key_name
  tags = {
    Name = "MicroK8s-SonarQube-Instance"
  }
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
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
