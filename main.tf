provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-0e7cbec6664f10896" // Replace with the Ubuntu 18.04 LTS AMI ID for your region
  instance_type = "t2.large"
  tags = {
    Name = "MicroK8s-SonarQube-Instance"
  }
  security_groups = [aws_security_group.instance_sg.id]
}

resource "aws_security_group" "instance_sg" {
  name_prefix = "Instance-SG-"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  
   }
}

output "ec2_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
