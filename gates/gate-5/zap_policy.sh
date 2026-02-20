#!/usr/bin/env bash
set -euo pipefail

echo "🕷️ Gate-4: ZAP DAST Policy"

REPORT="zap-report/zap-report.html"

# --------------------------------------------
# 1️⃣ Check Report Exists
# --------------------------------------------
if [ ! -f "$REPORT" ]; then
  echo "❌ ZAP HTML report not found!"
  exit 2
fi

echo "🔎 Analyzing HTML report..."

# --------------------------------------------
# 2️⃣ Extract Alert Counts From HTML
# --------------------------------------------

# Count High alerts
HIGH_COUNT=$(grep -o "High (" "$REPORT" | wc -l)

# Count Medium alerts
MEDIUM_COUNT=$(grep -o "Medium (" "$REPORT" | wc -l)

echo "High Alerts: $HIGH_COUNT"
echo "Medium Alerts: $MEDIUM_COUNT"

# --------------------------------------------
# 3️⃣ Policy Logic
# --------------------------------------------

if [ "$HIGH_COUNT" -gt 0 ]; then
  echo "❌ High risk vulnerabilities found"
  exit 1
fi

if [ "$MEDIUM_COUNT" -gt 2 ]; then
  echo "❌ Too many Medium vulnerabilities"
  exit 1
fi

echo "✅ DAST policy compliant"
