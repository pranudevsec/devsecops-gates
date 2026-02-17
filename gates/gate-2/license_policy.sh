#!/usr/bin/env bash
set -euo pipefail

echo "📜 Gate-2: License Policy"

FORBIDDEN="GPL|AGPL|LGPL"

if [ ! -f dependency-check-report.json ]; then
  echo "❌ Report not found"
  exit 2
fi

jq -r '.dependencies[].licenses[]?.license?.name // empty' dependency-check-report.json \
  | grep -E "$FORBIDDEN" && {
      echo "❌ Forbidden license detected"
      exit 1
    } || true

echo "✅ License policy compliant"

