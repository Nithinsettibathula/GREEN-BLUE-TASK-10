# --- Security Group for ECS Tasks ---
resource "aws_security_group" "ecs_sg" {
  name        = "${var.resource_prefix}-ecs-sg"
  description = "Allow inbound from ALB on 1337"
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

# --- ECS Cluster ---
resource "aws_ecs_cluster" "main" {
  name = "${var.resource_prefix}-cluster"
}

# --- ECS Task Definition ---
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
    # Using the custom ECR image built by your pipeline
    image = "${var.ecr_repository_url}:latest"
    
    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
      protocol      = "tcp"
    }]
    
    environment = [
      { name = "DATABASE_CLIENT",   value = "postgres" },
      { name = "DATABASE_HOST",     value = var.db_host },
      { name = "DATABASE_PORT",     value = "5432" },
      { name = "DATABASE_NAME",     value = "strapi" },
      { name = "DATABASE_USERNAME", value = var.db_username },
      { name = "DATABASE_PASSWORD", value = var.db_password },
      { name = "NODE_ENV",          value = "production" }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        # This name will now include 'v2' from your prefix
        "awslogs-group"         = "/ecs/${var.resource_prefix}-logs"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
        # Tells the ECS agent to create the group if your user cannot
        "awslogs-create-group"  = "true" 
      }
    }
  }])
}

# --- ECS Service ---
resource "aws_ecs_service" "main" {
  name            = "${var.resource_prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  # This connects the service to CodeDeploy for Blue/Green
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false 
  }

  load_balancer {
    target_group_arn = var.blue_tg_arn
    container_name   = "strapi-container"
    container_port   = 1337
  }

  # Terraform should ignore changes made by CodeDeploy during traffic shifts
  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}