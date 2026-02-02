terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1" 
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "test" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"

  key_name = "raktai"

  vpc_security_group_ids = [
    "sg-0409cda7089815018"
  ]

  root_block_device {
    volume_size = 30        
    volume_type = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "tf-test-ec2"
  }
}
