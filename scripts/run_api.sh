#!/usr/bin/env bash
set -e
# 이미 떠있는 컨테이너 있으면 종료
if docker ps --format '{{.Image}}' | grep -q '^tbi-api$'; then
  echo "[i] tbi-api already running"
else
  echo "[i] starting tbi-api on port 8000..."
  docker run --rm -p 8000:8000 -e MODEL_DIR=/app/models tbi-api
fi
