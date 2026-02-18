#!/bin/bash
set -e

TARGET=$1

if [ -z "$TARGET" ]; then
  echo "❌ Target IP not provided"
  exit 1
fi

echo "====================================="
echo "🔐 Gate-4: Transport Security (TLS)"
echo "Target: $TARGET"
echo "====================================="

mkdir -p security-reports/nmap

nmap --script ssl-enum-ciphers -p 443 $TARGET \
  -oN security-reports/nmap/tls-report.txt

echo "Analyzing TLS configuration..."

if grep -E 'TLSv1.0|TLSv1.1|3DES|RC4|NULL|EXPORT' security-reports/nmap/tls-report.txt; then
  echo "❌ Weak TLS version or cipher suite detected!"
  exit 1
else
  echo "✅ TLS configuration is secure"
fi
