resource "aws_security_group" "ecs_sg" {
  name        = "${var.resource_prefix}-ecs-sg"
  vpc_id      = var.vpc_id
  ingress {
    protocol        = "tcp"
    from_port       = 1337
    to_port         = 1337
    security_groups = [var.alb_sg_id]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.resource_prefix}-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.resource_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn

  container_definitions = jsonencode([{
    name  = "strapi-container"
    image = "${var.ecr_repository_url}:latest"
    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.resource_prefix}-logs"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
        "awslogs-create-group"  = "true"
      }
    }
  }])
}

resource "aws_ecs_service" "main" {
  name            = "${var.resource_prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true # Enabled to resolve ECR pull issues
  }

  load_balancer {
    target_group_arn = var.blue_tg_arn
    container_name   = "strapi-container"
    container_port   = 1337
  }

  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}