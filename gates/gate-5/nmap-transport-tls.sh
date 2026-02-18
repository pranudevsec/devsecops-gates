#!/bin/bash
set -e

if [ -z "$TARGET_IP" ]; then
  echo "❌ TARGET_IP not provided"
  exit 1
fi

TARGET=$TARGET_IP
PORT=${TARGET_PORT:-8001}

echo "====================================="
echo "🌐 Gate-5: HTTP Transport Security Check"
echo "Target: $TARGET"
echo "Port: $PORT"
echo "====================================="

mkdir -p security-reports/nmap

echo "🔍 Checking if port $PORT is open..."

nmap -p $PORT $TARGET -oN security-reports/nmap/http-port-report.txt

echo "🔎 Checking HTTP response..."

curl -I http://$TARGET:$PORT \
  > security-reports/nmap/http-header-report.txt

echo "Analyzing HTTP headers..."

if grep -q "Server:" security-reports/nmap/http-header-report.txt; then
  echo "⚠ Server header exposed (informational)"
fi

if ! grep -q "X-Content-Type-Options" security-reports/nmap/http-header-report.txt; then
  echo "❌ Missing X-Content-Type-Options header"
  exit 1
fi

echo "✅ HTTP transport checks completed"

