#  ubuntu server
resource "aws_instance" "jenkins_instance"{
  ami = "ami-0df609f69029c9bdb"
  count = 1
  instance_type = "t2.medium"
  key_name = "sydney"
  associate_public_ip_address = true
  user_data = <<EOF
  #!/bin/bash
  sudo yum update –y
  sudo yum install wget -y
  sudo yum install git -y
  sudo wget -O /etc/yum.repos.d/jenkins.repo \https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  sudo amazon-linux-extras install epel -y
  sudo yum upgrade
  sudo amazon-linux-extras install java-openjdk11 -y
  sudo yum install jenkins -y
  sudo systemctl enable jenkins 
  sudo systemctl start jenkins
  sudo systemctl status jenkin
              EOF

  tags = {
    Name = "jenkins_instance"
  }  

}

# resource "aws_instance" "SonarQube_instance"{
#   ami = "ami-02a66f06b3557a897" 
#   count = 1
#   instance_type = "t2.medium"
#   key_name = "sydney"
#   associate_public_ip_address = true
#   user_data = <<EOF
#   #!/bin/bash
#   sudo yum install java-1.8.0 -y
#   sudo wget -O /etc/yum.repos.d/sonar.repo http://downloads.sourceforge.net/project/sonar-pkg/rpm/sonar.repo
#   sudo yum install sonar -y
#   sudo service sonar start
#   sudo service sonar status
#               EOF

#   tags = {
#     Name = "SonarQube_instance"
#   } 

# }

# resource "aws_instance" "nexus_instance"{
#   ami = "ami-02a66f06b3557a897"
#   count = 1
#   instance_type = "t2.medium"
#   key_name = "sydney"
#   associate_public_ip_address = true
#   user_data = <<EOF
#   #!/bin/bash


#               EOF

#   tags = {
#     Name = "nexus_instance"
#   } 

# }