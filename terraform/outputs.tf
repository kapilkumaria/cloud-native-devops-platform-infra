output "app_public_ip" {
  description = "Public IP of the app EC2 instance"
  value       = aws_instance.app.public_ip
}

output "frontend_url" {
  description = "Frontend URL"
  value       = "http://${aws_instance.app.public_ip}:3000"
}

output "backend_docs_url" {
  description = "FastAPI Swagger docs URL"
  value       = "http://${aws_instance.app.public_ip}:8000/docs"
}

output "ssh_command" {
  description = "SSH command"
  value       = "ssh -i ~/.ssh/YOUR_KEY.pem ubuntu@${aws_instance.app.public_ip}"
}
