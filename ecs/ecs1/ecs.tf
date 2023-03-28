       #  role for ecs-instance
resource "aws_iam_role" "ecs-instance-role" {
  name = "ecs-instance-role"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
}
data "aws_iam_policy_document" "ecs-instance-policy" {
   statement {
  actions = ["sts:AssumeRole"]
  principals {
  type = "Service"
  identifiers = ["ec2.amazonaws.com"]
  }
 }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
   role = "${aws_iam_role.ecs-instance-role.name}"
   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs-instance-role.id}"
#   provisioner "local-exec" {
#   command = "sleep 60"
#  }
}
        #  role for ecs-service
resource "aws_iam_role" "ecs-service-role" {
  name = "ecs-service-role"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
  role = "${aws_iam_role.ecs-service-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
  statement {
  actions = ["sts:AssumeRole"]
  principals {
  type = "Service"
  identifiers = ["ecs.amazonaws.com"]
  }
 }
}

resource "aws_iam_role" "ecs_Task_Execution_Role" {
  name               = "ecs_Task_Execution_Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "ecs_Task_Execution_Role"
  
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

resource "aws_iam_role_policy_attachment" "ecs_TaskExecutionRole_policy" {
  role       = aws_iam_role.ecs_Task_Execution_Role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role" "ecs_autoscalling_Role" {
  name               = "ecs_autoscalling_Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "ecs_autoscalling_Role"
  
  }
}

data "aws_iam_policy_document" "assume_role_policy_autoscalling" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_autoscalling_policy" {
  role       = aws_iam_role.ecs_autoscalling_Role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}
##########################################################
# AWS ECS-CLUSTER
#########################################################

resource "aws_ecs_cluster" "clovis_jill_cluster" {
  name = "clovis-jill-cluster"
  tags = {
   name = "clovis-jill-cluster"
   }
   
  }

  ###########################################################
# AWS ECS-EC2
###########################################################
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0c18f3cdeea1c220d"
  subnet_id              =  "subnet-0fd1bb418a3d742af" #CHANGE THIS
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ecs-instance-profile.name #CHANGE THIS
  vpc_security_group_ids = ["sg-0c8ff6325b6a88c76"] #CHANGE THIS
  key_name               = "sydney" #CHANGE THIS
  ebs_optimized          = "false"
  source_dest_check      = "false"
  user_data              = "${data.template_file.user_data.rendered}"

  tags = {
    name = "ecs_instance"
  }
}


data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"
}

resource "aws_ecs_task_definition" "task_definition" {
  container_definitions    = "${data.template_file.task_definition_json.rendered}"                                         # task defination json file location
  execution_role_arn       = aws_iam_role.ecs_Task_Execution_Role.arn #CHANGE THIS                                                                      # role for executing task
  family                   = "ecs-task-defination"                                                      # task name
  network_mode             = "awsvpc"                                                                                      # network mode awsvpc, brigde
  memory                   = "2048"
  cpu                      = "1024"
  requires_compatibilities = ["EC2"]                                                                                       # Fargate or EC2
  task_role_arn            = aws_iam_role.ecs_Task_Execution_Role.arn  #CHANGE THIS                                                                     # TASK running role
} 

data "template_file" "task_definition_json" {
  template = "${file("${path.module}/task_definition.json")}"
}

resource "aws_ecs_service" "service" {
  cluster                = "${aws_ecs_cluster.clovis_jill_cluster.id}"                                 # ecs cluster id
  desired_count          = 1                                                        # no of task running
  launch_type            = "EC2"                                                      # Cluster type ECS OR FARGATE
  name                   = "ecs-service"                                         # Name of service
  task_definition        = "${aws_ecs_task_definition.task_definition.arn}"        # Attaching Task to service

  load_balancer {
    container_name       = "ecs-container"                                  #"container_${var.component}_${var.environment}"
    container_port       = "80"
    target_group_arn     = "${aws_lb_target_group.lb_target_group.arn}"         # attaching load_balancer target group to ecs
 }
  network_configuration {
    security_groups       = ["sg-0c8ff6325b6a88c76"] #CHANGE THIS
    subnets               = ["subnet-0fd1bb418a3d742af", "subnet-04eacbeedc089b4a6"]  ## Enter the private subnet id
    assign_public_ip      = "false"
  }
  depends_on              = [aws_lb_listener.lb_listener]
}

####################################################################
# AWS ECS-ALB
#####################################################################

resource "aws_lb" "loadbalancer" {
  internal            = "false"  # internal = true else false
  name                = "ecs-alb"
  subnets             = ["subnet-0fd1bb418a3d742af", "subnet-04eacbeedc089b4a6"] # enter the private subnet 
  security_groups     = ["sg-0c8ff6325b6a88c76"] #CHANGE THIS
}


resource "aws_lb_target_group" "lb_target_group" {
  name        = "ecs-lb-target-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "vpc-0ea196af01148d083" # CHNAGE THIS
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
  default_action {
    target_group_arn = "${aws_lb_target_group.lb_target_group.id}"
    type             = "forward"
  }

  #certificate_arn   = "arn:aws:acm:us-east-1:689019322137:certificate/9fcdad0a-7350-476c-b7bd-3a530cf03090"
  load_balancer_arn = "${aws_lb.loadbalancer.arn}"
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "clovis-jill-log-group"
    tags = {
    name = "clovis-jill-log-group"
  }
}

resource "aws_launch_configuration" "ec2_launch_configuration" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs-instance-profile.name
  image_id                    = "ami-0c18f3cdeea1c220d"
  instance_type               = "t2.micro"
  key_name                    = "sydney"

  lifecycle {
    create_before_destroy = false
  }

  name_prefix = "lauch-configuration-"

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

}

resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  name                 = "ec2_autoscaling_group"
  launch_configuration = aws_launch_configuration.ec2_launch_configuration.name
  min_size             = 1
  max_size             = 2
  availability_zones = var.availability_zones
  

  lifecycle {
    create_before_destroy = false
  }
}

###############################################################
# AWS ECS-ROUTE53
###############################################################
# resource "aws_route53_zone" "r53_private_zone" {
#   name         = "vpn-devl.us.e10.c01.example.com."
#   private_zone = false
# }

# resource "aws_route53_record" "dns" {
#   zone_id = "${aws_route53_zone.r53_private_zone.zone_id}"
#   name    = "openapi-editor-devl"
#   type    = "A"

#   alias {
#     evaluate_target_health = false
#     name                   = "${aws_lb.loadbalancer.dns_name}"
#     zone_id                = "${aws_lb.loadbalancer.zone_id}"
#   }
# }

