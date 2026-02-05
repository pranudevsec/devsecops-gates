#!/usr/bin/env bash
set -euo pipefail

echo "📉 Gate-4: Error Rate Policy"

ERROR_RATE=$(jq '.aggregate.errorRate' perf-report.json)

awk "BEGIN {exit !($ERROR_RATE < 1)}"

echo "✅ Error rate compliant"
