resource "aws_instance" "ec2" {
  ami           = "ami-0aad10862ade98f27" # Ubuntu 24.04 AMD64
  instance_type = "t3.micro"

  key_name = aws_key_pair.ec2_key.key_name

  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "ec2"
  }

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }
}

