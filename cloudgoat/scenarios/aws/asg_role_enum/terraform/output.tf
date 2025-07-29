output "ec2_public_ip" {
  value = data.aws_instances.launched_by_asg.public_ips[0]
}

output "ssh_key_path" {
  value = "${path.module}/cloudgoat"
}

output "ssh_command" {
  value = "ssh -i ${path.module}/cloudgoat ec2-user@${data.aws_instances.launched_by_asg.public_ips[0]}"
}