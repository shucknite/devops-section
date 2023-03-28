# resource "aws_vpc" "lightfeather_vpc" {
#   cidr_block = var.vpc_cidr

#   tags = {
#     name = "lightfeather-vpc",
#   }

# }

# resource "aws_subnet" "lightfeather_subnet" {
#   vpc_id                  = aws_vpc.lightfeather_vpc.id
#   cidr_block              = cidrsubnet(aws_vpc.lightfeather_vpc.cidr_block, 8, 1) 
#   map_public_ip_on_launch = true
#   availability_zone       = var.availability_zones

#   tags = {
#     Name = "lightfeather-subnet",
#   }

# }

# resource "aws_subnet" "lightfeather_subnet2" {
#   vpc_id                  = aws_vpc.lightfeather_vpc.id
#   cidr_block              = cidrsubnet(aws_vpc.lightfeather_vpc.cidr_block, 8, 2) 
#   map_public_ip_on_launch = true
#   availability_zone       = var.availability_zones

#   tags = {
#     Name = "lightfeather-subnet2",
#   }

# }

# resource "aws_internet_gateway" "lightfeather_igw" {
#   vpc_id = aws_vpc.lightfeather_vpc.id

#   tags = {
#     Name = "lightfeather-igw"
#   }

# }

# resource "aws_route_table" "lightfeather-rt" {
#   vpc_id = aws_vpc.lightfeather_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.lightfeather_igw.id
#   }

#   tags = {
#     Name = "lightfeather-rt"
#   }

# }

# resource "aws_route_table_association" "subnet_route" {
#   subnet_id      = aws_subnet.lightfeather_subnet.id
#   route_table_id = aws_route_table.lightfeather-rt.id
# }

# resource "aws_route_table_association" "subnet_route2" {
#   subnet_id      = aws_subnet.lightfeather_subnet2.id
#   route_table_id = aws_route_table.lightfeather-rt.id
# }

# resource "aws_security_group" "lightfeather_sg" {
#   name   = "lightfeather-ecs-sg"
#   vpc_id = aws_vpc.lightfeather_vpc.id

#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress  {
#     from_port = 110
#     to_port = 110
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port = 0
#     to_port = 65535
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress  {
#     from_port = 25
#     to_port = 25
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress  {
#     from_port = 587
#     to_port = 587
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress  {
#     from_port = 465
#     to_port = 465
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress  {
#     from_port = 53
#     to_port = 53
#     protocol = "udp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

# ingress {
#     from_port = 3306
#     to_port = 3306
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
# }

# ingress {
#     from_port = 443
#     to_port = 443
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
# }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#    tags = {
#     Name = "lightfeather_sg"
#   }

# }

# resource "aws_ecs_cluster" "lightfeather_cluster" {
#   name = "lightfeather-cluster"
#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }

#   tags = {
#     Name = "lightfeather-cluster"
#   }

# }

# resource "aws_ecs_task_definition" "lightfeather_task" {
#   family = "service"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE", "EC2"]
#   cpu                      = 512
#   memory                   = 2048
#   execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
#   task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

#   container_definitions = jsonencode([
#     {
#       name      = "backend",
#       image     = "shucknite/ngomo:latest"
#       cpu       = 10
#       memory    = 512
#       essential = true
#       portMappings = [
#         {
#           containerPort = 80
#           hostPort      = 80
#         }
#       ]
#     },
#     {
#       name      = "fronend"
#       image     = "shucknite/node:latest"
#       cpu       = 10
#       memory    = 256
#       essential = true
#       portMappings = [
#         {
#           containerPort = 3000
#           hostPort      = 3000
#         }
#       ]
#     }
#   ])

#    tags = {
#     Name = "lightfeather-tasks",
#   }

# }

# resource "aws_ecs_service" "lightfeather_service" {
#   name             = "lightfeather_service"
#   cluster          = aws_ecs_cluster.lightfeather_cluster.id
#   task_definition  = aws_ecs_task_definition.lightfeather_task.id
#   desired_count    = 1
#   launch_type      = "FARGATE"
#   platform_version = "LATEST"

#   network_configuration {
#     assign_public_ip = true
#     security_groups  = [aws_security_group.lightfeather_sg.id]
#     subnets          = [aws_subnet.lightfeather_subnet.id]
#   }
#   lifecycle {
#     ignore_changes = [task_definition]
#   }

#   tags = {
#     Name = "lightfeather_service",
#   }

# }

# resource "aws_iam_role" "ecsTaskExecutionRole" {
#   name               = "lightfeather-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
#   tags = {
#     Name        = "lightfeather-role",
  
#   }
# }

# data "aws_iam_policy_document" "assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
#   role       = aws_iam_role.ecsTaskExecutionRole.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
# }



resource "aws_vpc" "lightfeather_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    name = "lightfeather-vpc",
  }

}

resource "aws_subnet" "lightfeather_subnet" {
  vpc_id                  = aws_vpc.lightfeather_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.lightfeather_vpc.cidr_block, 8, 1) 
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones

  tags = {
    Name = "lightfeather-subnet",
  }

}

resource "aws_subnet" "lightfeather_subnet2" {
  vpc_id                  = aws_vpc.lightfeather_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.lightfeather_vpc.cidr_block, 8, 2) 
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones2

  tags = {
    Name = "lightfeather-subnet2",
  }

}

resource "aws_internet_gateway" "lightfeather_igw" {
  vpc_id = aws_vpc.lightfeather_vpc.id

  tags = {
    Name = "lightfeather-igw"
  }

}

resource "aws_route_table" "lightfeather-rt" {
  vpc_id = aws_vpc.lightfeather_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lightfeather_igw.id
  }

  tags = {
    Name = "lightfeather-rt"
  }

}

resource "aws_route_table_association" "subnet_route" {
  subnet_id      = aws_subnet.lightfeather_subnet.id
  route_table_id = aws_route_table.lightfeather-rt.id
}

resource "aws_route_table_association" "subnet_route2" {
  subnet_id      = aws_subnet.lightfeather_subnet2.id
  route_table_id = aws_route_table.lightfeather-rt.id
}

resource "aws_security_group" "lightfeather_sg" {
  name   = "lightfeather-ecs-sg"
  vpc_id = aws_vpc.lightfeather_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    from_port = 110
    to_port = 110
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    from_port = 25
    to_port = 25
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    from_port = 587
    to_port = 587
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    from_port = 465
    to_port = 465
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    from_port = 53
    to_port = 53
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {
    Name = "lightfeather_sg"
  }

}

resource "aws_ecs_cluster" "lightfeather_cluster" {
  name = "lightfeather-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "lightfeather-cluster"
  }

}

resource "aws_ecs_task_definition" "lightfeather_task" {
  family = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE", "EC2"]
  cpu                      = 512
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = jsonencode([
    {
      name      = "ngomo",
      image     = "shucknite/ngomo:latest"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
    {
      name      = "node-app"
      image     = "389302374367.dkr.ecr.ap-southeast-2.amazonaws.com/node-app:build-623a2676-8760-4a8e-97e0-42b36aa47f6e"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])

   tags = {
    Name = "lightfeather-tasks",
  }

}

resource "aws_ecs_service" "lightfeather_service" {
  name             = "lightfeather_service"
  cluster          = aws_ecs_cluster.lightfeather_cluster.id
  task_definition  = aws_ecs_task_definition.lightfeather_task.id
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.lightfeather_sg.id]
    subnets          = [aws_subnet.lightfeather_subnet.id]
  } 

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    container_name   = "ngomo"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    Name = "lightfeather_service",
  }

}

resource "aws_ecs_service" "lightfeather_service2" {
  name             = "lightfeather_service2"
  cluster          = aws_ecs_cluster.lightfeather_cluster.id
  task_definition  = aws_ecs_task_definition.lightfeather_task.id
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.lightfeather_sg.id]
    subnets          = [aws_subnet.lightfeather_subnet.id]
  } 

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group2.id
    container_name   = "node-app"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    Name = "lightfeather_service2",
  }

}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "lightfeather-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "lightfeather-role",
  
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_lb" "loadbalancer" {
  internal            = "false"  # internal = true else false
  name                = "ecs-alb"
  subnets             = [aws_subnet.lightfeather_subnet.id,aws_subnet.lightfeather_subnet2.id] # enter the private subnet 
  security_groups     = [aws_security_group.lightfeather_sg.id] #CHANGE THIS
}

resource "aws_lb" "loadbalancer2" {
  internal            = "false"  # internal = true else false
  name                = "ecs-alb2"
  subnets             = [aws_subnet.lightfeather_subnet.id,aws_subnet.lightfeather_subnet2.id] # enter the private subnet 
  security_groups     = [aws_security_group.lightfeather_sg.id] #CHANGE THIS
}


resource "aws_lb_target_group" "lb_target_group" {
  name        = "ecs-lb-target-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lightfeather_vpc.id # CHNAGE THIS
  target_type = "ip"


#STEP 1 - ECS task Running
  health_check {
    healthy_threshold   = "3"
    interval            = "10"
    port                = "80"
    path                = "/index.html"
    protocol            = "HTTP"
    unhealthy_threshold = "3"
  }
}

resource "aws_lb_target_group" "lb_target_group2" {
  name        = "ecs-lb-target-group2"
  port        = "8080"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lightfeather_vpc.id # CHNAGE THIS
  target_type = "ip"


#STEP 1 - ECS task Running
  health_check {
    healthy_threshold   = "3"
    interval            = "10"
    port                = "8080"
    path                = "/index.html"
    protocol            = "HTTP"
    unhealthy_threshold = "3"
  }
}

resource "aws_lb_listener" "lb_listener" {
  #certificate_arn   = "arn:aws:acm:us-east-1:689019322137:certificate/9fcdad0a-7350-476c-b7bd-3a530cf03090"
  load_balancer_arn = "${aws_lb.loadbalancer.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.id
  }
}

resource "aws_lb_listener" "lb_listener2" {
  #certificate_arn   = "arn:aws:acm:us-east-1:689019322137:certificate/9fcdad0a-7350-476c-b7bd-3a530cf03090"
  load_balancer_arn = "${aws_lb.loadbalancer2.arn}"
  port              = "80"
  protocol          = "HTTP"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:ap-southeast-2:389302374367:certificate/434cdd57-523d-42e3-82f6-0710509dceff"
  
    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group2.id
  }

}
