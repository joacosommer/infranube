output "instance_id" {
  description = "The ID of the instance"
  value       = aws_instance.web_server.id
}

output "public_ip" {
  description = "The public IP address of the instance"
  value       = aws_instance.web_server.public_ip
}

output "public_dns" {
  description = "The public DNS of the instance"
  value       = aws_instance.web_server.public_dns
}
