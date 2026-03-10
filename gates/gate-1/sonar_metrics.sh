#!/usr/bin/env bash
set -euo pipefail

echo "📊 Gate-1: SonarQube Metrics Enforcement (Overall Project)"

: "${SONAR_HOST_URL:?}"
: "${SONAR_TOKEN:?}"
: "${SONAR_PROJECT_KEY:?}"

MIN_COVERAGE=80
MAX_BUGS=0
MAX_VULNS=0

API_BASE="${SONAR_HOST_URL}/api"

echo "⏳ Waiting for SonarQube analysis..."
sleep 20

RESPONSE=$(curl -sf 
-u "${SONAR_TOKEN}:" 
-H "Accept: application/json" 
"${API_BASE}/measures/component?component=${SONAR_PROJECT_KEY}&metricKeys=coverage,bugs,vulnerabilities")

COVERAGE=$(echo "$RESPONSE" | jq -r '.component.measures[] | select(.metric=="coverage") | .value // "0"')
BUGS=$(echo "$RESPONSE" | jq -r '.component.measures[] | select(.metric=="bugs") | .value // "0"')
VULNS=$(echo "$RESPONSE" | jq -r '.component.measures[] | select(.metric=="vulnerabilities") | .value // "0"')

echo "📈 Coverage            : ${COVERAGE}%"
echo "🐞 Bugs                : ${BUGS}"
echo "🔐 Vulnerabilities     : ${VULNS}"

FAILED=0

if (( $(echo "$COVERAGE < $MIN_COVERAGE" | bc -l) )); then
echo "❌ Coverage < ${MIN_COVERAGE}%"
FAILED=1
fi

if [ "$BUGS" -gt "$MAX_BUGS" ]; then
echo "❌ Bugs detected"
FAILED=1
fi

if [ "$VULNS" -gt "$MAX_VULNS" ]; then
echo "❌ Vulnerabilities detected"
FAILED=1
fi

if [ "$FAILED" -eq 1 ]; then
echo "❌ Gate-1 METRICS CHECK FAILED"
exit 1
fi

echo "✅ Gate-1 METRICS CHECK PASSED"

