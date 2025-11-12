#!/usr/bin/env bash
set -e
echo "[i] serving /docs on port 5500..."
cd docs
python3 -m http.server 5500