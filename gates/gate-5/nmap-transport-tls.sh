#!/bin/bash
set -e

if [ -z "$TARGET_IP" ]; then
  echo "❌ TARGET_IP environment variable not provided"
  exit 1
fi

TARGET=$TARGET_IP
PORT=${TARGET_PORT:-443}   # default 443 if not provided

echo "====================================="
echo "🔐 Gate-5: Transport Security (TLS)"
echo "Target: $TARGET"
echo "Port: $PORT"
echo "====================================="

mkdir -p security-reports/nmap

echo "🔍 Running Nmap TLS scan..."

nmap --script ssl-enum-ciphers -p $PORT $TARGET \
  -oN security-reports/nmap/tls-report.txt

echo "🔎 Analyzing TLS configuration..."

if grep -E 'TLSv1\.0|TLSv1\.1|3DES|RC4|NULL|EXPORT' security-reports/nmap/tls-report.txt; then
  echo "❌ Weak TLS version or cipher suite detected!"
  exit 1
else
  echo "✅ TLS configuration is secure"
fi

