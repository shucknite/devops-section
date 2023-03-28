# redhat instance
resource "aws_instance" "eks_kubernetes_instance" {
  ami = "ami-051a81c2bd3e755db"
  count = 1
  instance_type = "t2.micro"
  key_name = "sydney"
  associate_public_ip_address = true

  tags = {
    Name = "eks_kubernetes_instance"
  }

}


