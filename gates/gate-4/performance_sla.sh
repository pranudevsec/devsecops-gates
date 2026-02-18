#!/bin/bash
set -e

echo "⏱ Gate-4: Response Time SLA"

REPORT_FILE="performance-report/results.jtl"

if [ ! -f "$REPORT_FILE" ]; then
  echo "❌ JMeter results file not found"
  exit 1
fi

# Skip CSV header row
AVG_RESPONSE=$(awk -F',' 'NR>1 {sum+=$2; count++} END {if (count>0) print sum/count; else print 0}' $REPORT_FILE)

echo "📊 Average Response Time: $AVG_RESPONSE ms"

# SLA threshold (2000 ms)
if echo "$AVG_RESPONSE > 2000" | bc -l | grep -q 1; then
  echo "❌ SLA breach: Avg response time exceeded 2000 ms"
  exit 1
fi

echo "✅ Response Time SLA Passed"

