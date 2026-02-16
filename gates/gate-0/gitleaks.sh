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
  -v "$PWD:/repo" \
  -v "$CONFIG_FILE:/config.toml:ro" \
  zricethezav/gitleaks:latest \
  detect \
    --source=/repo \
    --no-git \
    --config=/config.toml \
    --redact \
    --report-format=json \
    --report-path=/repo/$REPORT_FILE

# If report exists and is non-empty → check findings
if [ -s "$REPORT_FILE" ]; then
  COUNT=$(jq length "$REPORT_FILE" 2>/dev/null || echo 0)

  if [ "$COUNT" -gt 0 ]; then
    echo "❌ Gitleaks found $COUNT secrets"
    exit 1
  fi
fi

echo "✅ Gitleaks PASSED – No secrets detected"
exit 0

