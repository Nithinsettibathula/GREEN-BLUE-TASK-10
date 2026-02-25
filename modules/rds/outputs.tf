output "db_host" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.main.address
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "The master username for the database"
  value       = aws_db_instance.main.username
}