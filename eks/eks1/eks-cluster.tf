resource "aws_vpc" "eks_vpc"{
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name"= "eks_vpc"
  }
  
}


resource "aws_subnet" "eks_subnet"{
  cidr_block = "10.0.0.0/24"
  vpc_id = aws_vpc.eks_vpc.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name"= "eks_subnet"
  }

}
resource "aws_subnet" "eks_subnet2"{
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.eks_vpc.id
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name"= "eks_subnet2"
  }

}
resource "aws_subnet" "eks_subnet3"{
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.eks_vpc.id
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    "Name"= "eks_subnet3"
  }

}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    "Name"= "eks_igw"
  }

}

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    "Name"= "eks_rt"
  }

}

resource "aws_route_table_association" "myrta" {
  subnet_id      = aws_subnet.eks_subnet.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_route_table_association" "myrta2" {
  subnet_id      = aws_subnet.eks_subnet2.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_route_table_association" "myrta3" {
  subnet_id      = aws_subnet.eks_subnet3.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_route" "myr" {
  route_table_id = aws_route_table.myrt.id 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.myigw.id 
  depends_on = [
    aws_internet_gateway.myigw 
  ]
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks_cluster"
  role_arn = aws_iam_role.eks_iam_role.arn

    vpc_config {
    subnet_ids = [aws_subnet.eks_subnet.id, aws_subnet.eks_subnet2.id ,aws_subnet.eks_subnet3.id]
    security_group_ids      = [aws_security_group.eks_security_group.id]
  }
}

resource "aws_iam_role" "eks_iam_role" {
  name = "eks_iam_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_iam_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_iam_role.name
}

resource "aws_eks_node_group" "eks_node" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks_node_group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.eks_subnet.id, aws_subnet.eks_subnet2.id ,aws_subnet.eks_subnet3.id]
  


  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t2.micro"]

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_policy-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_policy-AmazonEC2ContainerRegistryReadOnly
    ]
    
    tags = {
    Name        = "eks_node"
  }

  }

resource "aws_iam_role" "eks_node_role" {
  name               = "eks_node_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name        = "eks_node_role"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_policy-AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_policy-AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_policy-AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_addon" "eks_node_addon" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"
}

resource "aws_security_group" "eks_security_group" {
  vpc_id = "${aws_vpc.eks_vpc.id}"

ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "rds-sg"
  }
}


# resource "aws_eks_fargate_profile" "eks_fargate" {
#   cluster_name           = aws_eks_cluster.eks_cluster.name
#   fargate_profile_name   = "eks_fargate"
#   pod_execution_role_arn = aws_iam_role.eks_farget_role.arn
#   subnet_ids             = [aws_subnet.eks_subnet.id, aws_subnet.eks_subnet2.id ,aws_subnet.eks_subnet3.id]

#   selector {
#     namespace = "farget-namespace"
#   }
# }

# resource "aws_iam_role" "eks_farget_role" {
#   name = "eks_farget_role"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "eks-fargate-pods.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEKSFargatePodExecutionRolePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
#   role       = aws_iam_role.eks_farget_role.name
# }