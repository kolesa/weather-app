provider "aws" {
  region = "us-west-2"
}

resource "aws_ecs_cluster" "weather_app_cluster" {
  name = "weather-app-cluster"
}

resource "aws_ecr_repository" "weather_app_repo" {
  name = "weather-app-repo"
}

resource "aws_iam_role" "weather_app_execution_role" {
  name = "weather_app_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Define an IAM policy that allows necessary ECR actions
resource "aws_iam_policy" "ecr_access" {
  name        = "ECRAccessPolicy"
  description = "Allows necessary ECR actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ecr-public:*",
          "sts:GetServiceBearerToken",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the ECR policy to the IAM role
resource "aws_iam_role_policy_attachment" "ecr_access_attachment" {
  role       = aws_iam_role.weather_app_execution_role.name
  policy_arn = aws_iam_policy.ecr_access.arn
}

resource "aws_ecs_task_definition" "weather_app_task" {
  family                   = "weather-app-task-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.weather_app_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "weather-app"
      image = "${aws_ecr_repository.weather_app_repo.repository_url}:latest"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

resource "aws_security_group" "weather_app_sg" {
  name        = "weather-app-sg"
  description = "SG for weather App"
  vpc_id      = "vpc-15c6126d"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "weather-app-sg"
  }
}

resource "aws_lb" "weather_app_alb" {
  name               = "weather-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.weather_app_sg.id]
  subnets            = ["subnet-346b4a4d", "subnet-aa9ad9e1"]

  enable_deletion_protection = false

  enable_cross_zone_load_balancing   = true
  idle_timeout                       = 300
  enable_http2                       = true

  tags = {
    Name = "weather-app-alb"
  }
}

resource "aws_lb_target_group" "weather_app_group" {
  name     = "weather-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-15c6126d"
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }
}

resource "aws_lb_listener" "weather_app_listener" {
  load_balancer_arn = aws_lb.weather_app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.weather_app_group.arn
  }
}

resource "aws_ecs_service" "weather_app_service" {
  name            = "weather-app-service"
  cluster         = aws_ecs_cluster.weather_app_cluster.id
  task_definition = aws_ecs_task_definition.weather_app_task.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets = ["subnet-346b4a4d", "subnet-02118d3c5d5bb1e28"]
    security_groups = [aws_security_group.weather_app_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.weather_app_group.arn
    container_name   = "weather-app"
    container_port   = 3000
  }
}

output "rails_ecs_cluster_name" {
  value = aws_ecs_cluster.weather_app_cluster.name
}

output "rails_ecr_repo_url" {
  value = aws_ecr_repository.weather_app_repo.repository_url
}
