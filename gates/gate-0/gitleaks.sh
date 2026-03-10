#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Gate-0A: Gitleaks Secret Detection"

REPORT_DIR="$WORKSPACE/security-reports/gitleaks"
REPORT_FILE="$REPORT_DIR/gitleaks-report.json"

mkdir -p "$REPORT_DIR"

# Resolve config path
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.gitleaks.toml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ ERROR: .gitleaks.toml not found"
  exit 2
fi

echo "📄 Using Gitleaks config: $CONFIG_FILE"
echo "📂 Jenkins workspace: $WORKSPACE"

# Run Gitleaks
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$WORKSPACE:/repo" 
  -v "$CONFIG_FILE:/config.toml:ro" \
  zricethezav/gitleaks:latest \
  detect \
    --source=/repo \
    --no-git \
    --config=/config.toml \
    --report-format=json \
    --report-path=/repo/$REPORT_FILE || true

# Ensure report always exists
if [ ! -f "$REPORT_FILE" ]; then
  echo "[]" > "$REPORT_FILE"
fi

COUNT=$(jq length "$REPORT_FILE" 2>/dev/null || echo 0)

if [ "$COUNT" -gt 0 ]; then
  echo "❌ Gitleaks found $COUNT secrets"
  echo "----------------------------------"
  jq -r '.[] | "File: \(.File)\nRule: \(.RuleID)\nLine: \(.StartLine)\n"' "$REPORT_FILE"
  echo "----------------------------------"
  exit 1
fi

echo "✅ Gitleaks PASSED – No secrets detected"
exit 0
