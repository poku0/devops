terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_key_pair" "n8n_key" {
  key_name   = "n8n-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}



