terraform {
  backend "s3" {
    bucket         = "povilas-terraform-state"
    key            = "51/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
# above block stores terraform state in s3 bucket and dynamodb table for state locking 

resource "aws_s3_bucket" "example" {}

resource "aws_instance" "app_server" {
  ami           = "ami-0aad10862ade98f27"
  instance_type = "t3.micro"

  depends_on = [aws_s3_bucket.example]

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

resource "aws_eip" "ip" {
  instance = aws_instance.app_server.id
}

variable "project" {
  description = "Map of project names to configuration"
  type        = map(any)
  default = {
    client-webapp = {
      instance_type = "t3.micro"
      environment   = "dev"
    },
    internal-webapp = {
      instance_type = "t3.micro"
      environment   = "dev"
    }
  }
}

resource "aws_instance" "for_each_example" {
  for_each      = var.project
  ami           = "ami-0aad10862ade98f27"
  instance_type = each.value.instance_type
  tags = {
    Name = each.value.environment
  }
}

resource "aws_instance" "if_example" {
  count         = var.create == "true" ? 1 : 0
  ami           = "ami-0aad10862ade98f27"
  instance_type = "t3.micro"
  tags = {
    Name = "if_example-${count.index}"
  }
}
