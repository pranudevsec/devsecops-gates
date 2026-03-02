#!/usr/bin/env bash
set -euo pipefail

echo "🚦 Gate-4: Performance Policy Enforcement"

RESULT_FILE="performance-report/results.csv"

if [ ! -f "$RESULT_FILE" ]; then
  echo "❌ Results file not found: $RESULT_FILE"
  exit 1
fi

FAIL=0

# -------------------------------
# 1️⃣ Calculate Metrics from CSV
# -------------------------------
echo "📊 Calculating performance metrics..."

TOTAL=$(awk -F, 'NR>1 {count++} END {print count+0}' "$RESULT_FILE")
FAILURES=$(awk -F, 'NR>1 && $8=="false" {count++} END {print count+0}' "$RESULT_FILE")
AVG_RESPONSE=$(awk -F, 'NR>1 {sum+=$2; count++} END {if(count>0) print int(sum/count); else print 0}' "$RESULT_FILE")

if [ "$TOTAL" -eq 0 ]; then
  echo "❌ No samples found in results file"
  exit 1
fi

ERROR_RATE=$(awk "BEGIN {printf \"%.2f\", ($FAILURES/$TOTAL)*100}")

echo "🔢 Total Requests: $TOTAL"
echo "❌ Failed Requests: $FAILURES"
echo "📉 Error Rate: $ERROR_RATE%"
echo "⏱️ Average Response Time: $AVG_RESPONSE ms"

# -------------------------------
# 2️⃣ Performance SLA Check
# -------------------------------
SLA_THRESHOLD=2000

echo "⏱️ Checking SLA (<= ${SLA_THRESHOLD} ms)..."

if awk "BEGIN {exit !($AVG_RESPONSE <= $SLA_THRESHOLD)}"; then
  echo "✅ SLA OK"
else
  echo "❌ SLA Violated"
  FAIL=1
fi

# -------------------------------
# 3️⃣ Error Rate Check
# -------------------------------
ERROR_THRESHOLD=1

echo "📉 Checking Error Rate (< ${ERROR_THRESHOLD}%)..."

if awk "BEGIN {exit !($ERROR_RATE < $ERROR_THRESHOLD)}"; then
  echo "✅ Error Rate OK"
else
  echo "❌ Error Rate Too High"
  FAIL=1
fi

# -------------------------------
# Final Decision
# -------------------------------
if [ "$FAIL" -eq 0 ]; then
  echo "🎉 Gate-4 PASSED: Performance policies satisfied"
  exit 0
else
  echo "🚫 Gate-4 FAILED: Performance policy violations detected"
  exit 1
fi
