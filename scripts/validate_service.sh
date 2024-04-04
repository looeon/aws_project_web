#!/bin/bash

# Apache 서비스 상태 확인
if sudo systemctl is-active --quiet httpd; then
  echo "Apache 서비스가 정상적으로 실행 중입니다."
  exit 0
else
  echo "Apache 서비스가 실행되지 않았습니다. 배포 실패!"
  exit 1
fi
