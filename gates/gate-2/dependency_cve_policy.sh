#!/usr/bin/env bash
set -euo pipefail

echo "🛡️ Gate-2: Dependency CVE Policy"

REPORT="dependency-check-report.json"

CRITICAL=$(jq '[.dependencies[].vulnerabilities[]? | select(.severity=="CRITICAL")] | length' "$REPORT")
HIGH=$(jq '[.dependencies[].vulnerabilities[]? | select(.severity=="HIGH")] | length' "$REPORT")

[ "$CRITICAL" -eq 0 ] || exit 1
[ "$HIGH" -le 5 ] || exit 1

echo "✅ CVE policy compliant"
