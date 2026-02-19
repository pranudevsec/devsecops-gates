#!/bin/bash
set -e

echo "⏱ Gate-4: Response Time SLA"

REPORT_FILE="performance-report/results.csv"

if [ ! -f "$REPORT_FILE" ]; then
  echo "❌ JMeter results file not found"
  exit 0
fi

AVG_RESPONSE=$(awk -F',' 'NR>1 {sum+=$2; count++} END {if (count>0) print sum/count; else print 0}' $REPORT_FILE)

echo "Average Response Time: $AVG_RESPONSE ms"

if echo "$AVG_RESPONSE > 2000" | bc -l | grep -q 1; then
  echo "❌ SLA breach: Avg response time exceeded 2000 ms"
  exit 0
fi

echo "✅ Response Time SLA Passed"

