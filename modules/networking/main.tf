resource "aws_security_group" "alb_sg" {
  name        = "${var.resource_prefix}-alb-sg"
  vpc_id      = var.vpc_id
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
}

# --- VPC Endpoints for ECR (The Professional Fix) ---
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.alb_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.alb_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.vpc_id] # Replace with your private route table ID if known
}

# --- Target Groups ---
resource "aws_lb_target_group" "blue" {
  name        = "${var.resource_prefix}-tg-blue"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/admin"
  }
}

resource "aws_lb_target_group" "green" {
  name        = "${var.resource_prefix}-tg-green"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/admin"
  }
}