# 현재 사용 중인 AWS 계정 정보
data "aws_caller_identity" "current" {}

# 현재 Terraform이 실행 중인 AWS 리전
data "aws_region" "current" {}

# Amazon Linux 2 AMI (리전별로 최신 버전 조회)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}