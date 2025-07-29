data "aws_instances" "launched_by_asg" {
  filter {
    name   = "tag:Name"
    values = ["Privileged1-LaunchTemplate"]
  }

  filter {
    name   = "whs_fronted"
    values = ["running"]
  }

  depends_on = [aws_autoscaling_group.whs_fronted_asg]
} 