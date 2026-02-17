resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet["cidr_block"]
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet["Name"]
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet["cidr_block"]

  tags = {
    Name = var.private_subnet["Name"]
  }
}