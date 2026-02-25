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

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "${var.ecr_repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "DATABASE_HOST", value = var.db_host },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = "strapi" },
        { name = "DATABASE_USERNAME", value = var.db_username },
        { name = "DATABASE_PASSWORD", value = var.db_password },
        { name = "NODE_ENV", value = "production" }
      ]
    }
  ])
}

# --- ECS Security Group ---
resource "aws_security_group" "ecs_sg" {
  name        = "${var.resource_prefix}-ecs-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- ECS Service (Configured for Public Access to pull images) ---
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
    # Tasks are in public subnets with Public IP enabled to reach ECR
    subnets          = var.public_subnets 
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true 
  }

  load_balancer {
    target_group_arn = var.blue_tg_arn
    container_name   = "strapi"
    container_port   = 1337
  }

  lifecycle {
    ignore_changes = [
      load_balancer,
      task_definition,
    ]
  }
}

# --- MODULE OUTPUTS (Required by main.tf and CodeDeploy) ---

output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "ecs_sg_id" {
  description = "The ID of the ECS security group"
  value       = aws_security_group.ecs_sg.id
}