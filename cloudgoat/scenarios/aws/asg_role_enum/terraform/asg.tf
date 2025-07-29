# 이건 실행되게끔 해야함 
resource "aws_autoscaling_group" "whs_fronted_asg" {
  name                      = "cg-whs-fronted-asg"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.public.id]

  launch_template {
    id      = aws_launch_template.privileged1.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "cg-whs-fronted-asg-ec2"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

#2
resource "aws_autoscaling_group" "whs_backend_asg" {
  name                      = "cg-whs-backend-asg"
  max_size                  = 1
  min_size                  = 0
  desired_capacity          = 0
  vpc_zone_identifier       = [aws_subnet.private.id]

  launch_template {
    id      = aws_launch_template.privileged2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "cg-whs-backend-asg-ec2"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#3
resource "aws_autoscaling_group" "whs_worker_asg" {
  name                      = "cg-whs-worker-asg"
  max_size                  = 1
  min_size                  = 0
  desired_capacity          = 0
  vpc_zone_identifier       = [aws_subnet.private.id]

  launch_template {
    id      = aws_launch_template.privileged3.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "cg-whs-worker-asg-ec2"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#4
resource "aws_autoscaling_group" "whs_admin_api_asg" {
  name                      = "cg-whs-admin-api-asg"
  max_size                  = 1
  min_size                  = 0
  desired_capacity          = 0
  vpc_zone_identifier       = [aws_subnet.private.id]

  launch_template {
    id      = aws_launch_template.privileged4.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "cg-whs-admin-api-asg-ec2"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

