resource "aws_key_pair" "cg_key" {
  key_name   = "cg-key-pair-${var.cgid}"
  public_key = file(var.ssh_public_key)
}

resource "aws_launch_template" "privileged1" {
  name_prefix   = "cg-privileged-1-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  key_name = aws_key_pair.cg_key.key_name  # ← SSH 키 페어 연결
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_describe_asg_profile.name
  }
  network_interfaces {
    device_index                = 0
    associate_public_ip_address = true              
    subnet_id                   = aws_subnet.public.id # 서브넷 연결
    security_groups             = [aws_security_group.cg_ssh.id]  # SG 연결
  }
  tag_specifications{
  resource_type = "instance"
  tags = {
    Name = "Privileged1-LaunchTemplate"
  }
  }
}

resource "aws_launch_template" "privileged2" {
  name_prefix   = "cg-privileged-2-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.cg_key.key_name  # ← SSH 키 페어 연결
  network_interfaces {
    device_index                = 0
    associate_public_ip_address = false               
    subnet_id                   = aws_subnet.private.id # 서브넷 연결
    security_groups             = [aws_security_group.cg_ssh.id]  # SG 연결
  }
  tag_specifications{
  resource_type = "instance"
  tags = {
    Name = "Privileged2-LaunchTemplate"
  }
  }
}

resource "aws_launch_template" "privileged3" {
  name_prefix   = "cg-privileged-3-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.cg_key.key_name  # ← SSH 키 페어 연결
  network_interfaces {
    device_index                = 0
    associate_public_ip_address = false               
    subnet_id                   = aws_subnet.private.id # 서브넷 연결
    security_groups             = [aws_security_group.cg_ssh.id]  # SG 연결
  }
  tag_specifications{
  resource_type = "instance"
  tags = {
    Name = "Privileged3-LaunchTemplate"
  }
  }
}

resource "aws_launch_template" "privileged4" {
  name_prefix   = "cg-privileged-4-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.cg_key.key_name  # ← SSH 키 페어 연결
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_athena_query_profile.name
  }
  network_interfaces {
    device_index                = 0
    associate_public_ip_address = false               
    subnet_id                   = aws_subnet.private.id # 서브넷 연결
    security_groups             = [aws_security_group.cg_ssh.id]  # SG 연결
  }
  tag_specifications {
  resource_type = "instance"
  tags = {
    Name = "Privileged4-LaunchTemplate"
  }
  }
}

# ec2를 새로 만드는 시작 템플릿  
resource "aws_launch_template" "startEc2" {
  name_prefix   = "cg-start-Ec2"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.cg_key.key_name  # ← SSH 키 페어 연결
  network_interfaces {
    device_index                = 0
    associate_public_ip_address = false               
    subnet_id                   = aws_subnet.private.id # 서브넷 연결
    security_groups             = [aws_security_group.cg_deny_ssh.id]  # SG 연결
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "startEc2-LaunchTemplate"
    }
  }
}


