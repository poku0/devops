resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "main2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1b"
}

resource "aws_instance" "my_vm" {
  count         = 2
  ami           = "ami-0bae57ee7c4478e01"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  tags = {
    Name = "my_-main-vm-${count.index}"
  }
}


resource "aws_vpc" "secondary" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "secondary" {
  vpc_id     = aws_vpc.secondary.id
  cidr_block = "10.1.0.0/24"
}

resource "aws_instance" "my_vm2" {
  count         = 2
  ami           = "ami-0bae57ee7c4478e01"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.secondary.id
  tags = {
    Name = "my_secondary-vm-${count.index}"
  }
}

resource "aws_security_group" "main" {
  name        = "main-sg"
  description = "Main security group"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "main" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.main.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb" "main" {
  name               = "main-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = [aws_subnet.main.id, aws_subnet.main2.id]
}

resource "aws_lb_target_group" "main" {
  name     = "main-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}