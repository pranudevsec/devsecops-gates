#!/bin/bash
set -e

echo "⏱ Gate-4: Response Time SLA"

REPORT_FILE="performance-report/results.jtl"

if [ ! -f "$REPORT_FILE" ]; then
  echo "❌ JMeter results file not found"
  exit 1
fi

AVG_RESPONSE=$(awk -F',' '{sum+=$2} END {if (NR>0) print sum/NR; else print 0}' $REPORT_FILE)

echo "Average Response Time: $AVG_RESPONSE ms"

if (( $(echo "$AVG_RESPONSE > 2000" | bc -l) )); then
  echo "❌ SLA breach: Avg response time exceeded 2000 ms"
  exit 1
fi

echo "✅ Response Time SLA Passed"

