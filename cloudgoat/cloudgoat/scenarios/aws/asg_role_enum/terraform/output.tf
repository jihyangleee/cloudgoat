output "attacker_public_ip" {
  description = "Public IP of attacker EC2"
  value       = aws_instance.attacker.public_ip
}

output "attacker_private_key_pem" {
  description = "PEM key used to connect"
  value       = file("${path.module}/cloudgoat")
  sensitive   = true
}