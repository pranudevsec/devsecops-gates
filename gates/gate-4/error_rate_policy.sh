#!/bin/bash
set -e

echo "📉 Gate-4: Error Rate Policy"

REPORT_FILE="performance-report/results.jtl"

if [ ! -f "$REPORT_FILE" ]; then
  echo "❌ JMeter results file not found"
  exit 1
fi

FAILED=$(awk -F',' '$8 == "false" {count++} END {print count+0}' $REPORT_FILE)

echo "Failed Requests: $FAILED"

if [ "$FAILED" -gt 5 ]; then
  echo "❌ Error rate exceeded threshold (5)"
  exit 1
fi

echo "✅ Error Rate Policy Passed"

