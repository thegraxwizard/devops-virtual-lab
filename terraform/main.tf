provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-vle5-sg"
  description = "Security group for VLE5 DevOps server"
  vpc_id      = data.aws_vpc.default.id

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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevOps-VLE5-SG"
  }
}

resource "aws_instance" "devops_server" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t3.micro"
  key_name                    = "my-key"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "DevOps-Lab-Server"
  }
}

output "instance_id" {
  value = aws_instance.devops_server.id
}

output "public_ip" {
  value = aws_instance.devops_server.public_ip
}
