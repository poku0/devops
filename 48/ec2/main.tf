terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}



