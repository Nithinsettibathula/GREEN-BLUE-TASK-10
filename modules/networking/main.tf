

# --- ALB Security Group ---
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

# --- Application Load Balancer ---
resource "aws_lb" "main" {
  name               = "${var.resource_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets
}

# --- ALB Listeners ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

# --- Target Groups (Blue & Green) ---
resource "aws_lb_target_group" "blue" {
  name        = "${var.resource_prefix}-tg-blue"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/_health"   # Strapi default health path
    matcher             = "200-299"    # FIX: Accept 204 (No Content) which Strapi returns
    interval            = 60           # FIX: Check less frequently (every 60s)
    timeout             = 30           # FIX: Give it 30s to respond
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}

resource "aws_lb_target_group" "green" {
  name        = "${var.resource_prefix}-tg-green"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/_health"
    matcher             = "200-299"    # FIX: Accept 204
    interval            = 60
    timeout             = 30
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}

