#!/bin/bash
set -euo pipefail

# 특정 Launch Template 이름 (prefix 허용)
LAUNCH_TEMPLATE_NAME="cg-start-Ec2*"

echo "[*] Launch Template 이름이 '${LAUNCH_TEMPLATE_NAME}'인 EC2 인스턴스를 종료 중..."

INSTANCE_IDS=$(aws ec2 describe-instances \
  --filters "Name=launch-template.name,Values=${LAUNCH_TEMPLATE_NAME}" \
            "Name=instance-state-name,Values=running,stopped,pending" \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output text)

if [[ -n "$INSTANCE_IDS" ]]; then
  echo "[+] 다음 인스턴스를 종료합니다: $INSTANCE_IDS"
  aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
else
  echo "[ℹ️] 종료할 EC2 인스턴스가 없습니다."
fi

echo "[✅] EC2 인스턴스 정리 완료."
