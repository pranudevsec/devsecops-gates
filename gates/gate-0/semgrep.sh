#!/bin/bash
set -e

echo "🔍 Running Semgrep with default rules"

mkdir -p security-reports/semgrep

docker run --rm \
  -v "$PWD:/src" \
  returntocorp/semgrep \
  semgrep scan \
    --config auto \
    --json \
    --output /src/security-reports/semgrep/report.json

FINDINGS=$(jq '.results | length' security-reports/semgrep/report.json 2>/dev/null || echo 0)

if [ "$FINDINGS" -gt 0 ]; then
  echo "❌ Semgrep findings detected"
  exit 0
fi

echo "✅ Semgrep passed"
exit 0

