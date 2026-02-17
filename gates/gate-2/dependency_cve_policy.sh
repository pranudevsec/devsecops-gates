#!/usr/bin/env bash
set -euo pipefail

echo "🛡️ Gate-2: Dependency CVE Policy"

REPORT="dependency-check-report.json"

if [ ! -f "$REPORT" ]; then
  echo "❌ Report not found: $REPORT"
  exit 2
fi

CRITICAL=$(jq '[.dependencies[].vulnerabilities[]? | select(.severity=="CRITICAL")] | length' "$REPORT")
HIGH=$(jq '[.dependencies[].vulnerabilities[]? | select(.severity=="HIGH")] | length' "$REPORT")

echo "🔎 Vulnerability Summary:"
echo "CRITICAL: $CRITICAL"
echo "HIGH: $HIGH"

# 🔴 STRICT CRITICAL POLICY
if [ "$CRITICAL" -ne 0 ]; then
  echo "❌ CRITICAL vulnerabilities must be 0"
  exit 1
fi

# 🟠 HIGH POLICY
if [ "$HIGH" -gt 5 ]; then
  echo "❌ Too many HIGH vulnerabilities"
  exit 1
fi

echo "✅ CVE policy compliant"

