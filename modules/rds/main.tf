# --- RDS Subnet Group ---
resource "aws_db_subnet_group" "main" {
  name       = "${var.resource_prefix}-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.resource_prefix}-db-subnet-group"
  }
}

# --- Security Group for RDS ---
resource "aws_security_group" "rds_sg" {
  name        = "${var.resource_prefix}-rds-sg"
  description = "Allow inbound PostgreSQL traffic from ECS"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    # This allows ONLY the ECS tasks to talk to the database
    security_groups = [var.ecs_sg_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- RDS PostgreSQL Instance ---
resource "aws_db_instance" "main" {
  identifier           = "${var.resource_prefix}-db"
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = "db.t4g.micro"
  allocated_storage     = 20
  db_name              = "strapi"
  username             = "strapi"
  # Now using the variable passed from root
  password             = var.db_password 
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true

  tags = {
    Name = "${var.resource_prefix}-db"
  }
}

