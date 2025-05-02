provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "key" {
  key_name   = "terraform-key"
  public_key = file("${path.module}/id_rsa.pub")
}

resource "aws_security_group" "ubuntu_sg" {
  name        = "ubuntu-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (not secure in production)
  }

  ingress {
    description = "HTTP"
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
    Name = "ubuntu-sg"
  }
}
data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "ubuntu" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key.key_name

  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]

  tags = {
    Name = "UbuntuVM"
  }
}

