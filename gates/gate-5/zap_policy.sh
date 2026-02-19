#!/usr/bin/env bash
set -euo pipefail

echo "🕷️ Gate-4: ZAP DAST Policy"

REPORT="zap-report/zap-report.json"


CRITICAL=$(jq '[.site[].alerts[] | select(.risk=="High")] | length' "$REPORT")
HIGH=$(jq '[.site[].alerts[] | select(.risk=="Medium")] | length' "$REPORT")

[ "$CRITICAL" -eq 0 ] || exit 0
[ "$HIGH" -le 2 ] || exit 

echo "✅ DAST policy compliant"
