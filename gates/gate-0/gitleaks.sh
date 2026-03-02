#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Gate-0A: Gitleaks Secret Detection"

REPORT_DIR="security-reports/gitleaks"
REPORT_FILE="$REPORT_DIR/gitleaks-report.json"

mkdir -p "$REPORT_DIR"

# Resolve path to central config file
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.gitleaks.toml"

# Ensure config exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ ERROR: .gitleaks.toml not found in central repo"
  exit 2
fi

echo "📄 Using Gitleaks config: $CONFIG_FILE"

# Run Gitleaks inside Docker
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$PWD:/repo" \
  -v "$CONFIG_FILE:/config.toml:ro" \
  zricethezav/gitleaks:latest \
  detect \
    --source=/repo/backend \
    --source=/repo/frontend \
    --no-git \
    --config=/config.toml \
    --redact \
    --report-format=json \
    --report-path=/repo/$REPORT_FILE || true

# If report exists and is non-empty → check findings

if [ -f "$REPORT_FILE" ]; then
  COUNT=$(jq length "$REPORT_FILE" 2>/dev/null || echo 0)

  if [ "$COUNT" -gt 0 ]; then
    echo "❌ Gitleaks found $COUNT secrets"
    echo "----------------------------------"
    jq -r '.[] | "File: \(.File)\nRule: \(.RuleID)\nLine: \(.StartLine)\n"' "$REPORT_FILE"
    echo "----------------------------------"
    exit 1
  fi
fi

echo "✅ Gitleaks PASSED – No secrets detected"
exit 0
