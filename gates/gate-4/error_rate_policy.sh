#!/bin/bash
set -e

echo "📉 Gate-4: Error Rate Policy"

REPORT_FILE="performance-report/results.csv"

if [ ! -f "$REPORT_FILE" ]; then
  echo "❌ JMeter results file not found"
  exit 0
fi

# Count failures (success column = false)
FAILED=$(awk -F',' 'NR>1 && $8=="false" {count++} END {print count+0}' $REPORT_FILE)

TOTAL=$(awk -F',' 'NR>1 {count++} END {print count+0}' $REPORT_FILE)

echo "Total Requests: $TOTAL"
echo "Failed Requests: $FAILED"

if [ "$TOTAL" -gt 0 ]; then
  ERROR_RATE=$(echo "scale=2; ($FAILED/$TOTAL)*100" | bc)
else
  ERROR_RATE=0
fi

echo "Error Rate: $ERROR_RATE %"

if echo "$ERROR_RATE > 5" | bc -l | grep -q 1; then
  echo "❌ Error rate exceeded 5%"
  exit 0
fi

echo "✅ Error Rate Policy Passed"

