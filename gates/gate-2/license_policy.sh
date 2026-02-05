#!/usr/bin/env bash
set -euo pipefail

echo "📜 Gate-2: License Policy"

FORBIDDEN="GPL|AGPL|LGPL"

jq -r '.dependencies[].licenses[].license.name' dependency-check-report.json \
  | grep -E "$FORBIDDEN" && exit 1 || true

echo "✅ License policy compliant"
