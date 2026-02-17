#!/usr/bin/env bash
set -euo pipefail

echo "🛡️ Gate-2: CVSS-Based Vulnerability Policy"

REPORT="dependency-check-report.json"

if [ ! -f "$REPORT" ]; then
  echo "❌ Report not found: $REPORT"
  exit 2
fi

# Count CVSS >= 9.0 (Critical)
CRITICAL_COUNT=$(jq '
  [.dependencies[].vulnerabilities[]? 
   | (.cvssv3.baseScore // .cvssv2.score // 0) 
   | select(. >= 9.0)] 
  | length
' "$REPORT")

# Count CVSS >= 7.0 and < 9.0 (High)
HIGH_COUNT=$(jq '
  [.dependencies[].vulnerabilities[]? 
   | (.cvssv3.baseScore // .cvssv2.score // 0) 
   | select(. >= 7.0 and . < 9.0)] 
  | length
' "$REPORT")

echo "🔎 CVSS Summary:"
echo "Critical (>=9.0): $CRITICAL_COUNT"
echo "High (>=7.0 <9.0): $HIGH_COUNT"

if [ "$CRITICAL_COUNT" -ne 0 ]; then
  echo "❌ CVSS >= 9.0 vulnerabilities detected"
  exit 1
fi

if [ "$HIGH_COUNT" -gt 5 ]; then
  echo "❌ Too many CVSS >= 7.0 vulnerabilities"
  exit 1
fi

echo "✅ CVSS policy compliant"

