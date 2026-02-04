#!/usr/bin/env bash
set -euo pipefail

echo "📊 Gate-1: SonarQube Metrics Enforcement (New Code)"

: "${SONAR_HOST_URL:?}"
: "${SONAR_TOKEN:?}"
: "${SONAR_PROJECT_KEY:?}"

MIN_NEW_COVERAGE=80
MAX_NEW_BUGS=0
MAX_NEW_VULNS=0

API_BASE="${SONAR_HOST_URL}/api"

RESPONSE=$(curl -sf \
  -u "${SONAR_TOKEN}:" \
  -H "Accept: application/json" \
  "${API_BASE}/measures/component?component=${SONAR_PROJECT_KEY}&metricKeys=new_coverage,new_bugs,new_vulnerabilities")

NEW_COVERAGE=$(echo "$RESPONSE" | jq -r '.component.measures[] | select(.metric=="new_coverage") | .value // "0"')
NEW_BUGS=$(echo "$RESPONSE" | jq -r '.component.measures[] | select(.metric=="new_bugs") | .value // "0"')
NEW_VULNS=$(echo "$RESPONSE" | jq -r '.component.measures[] | select(.metric=="new_vulnerabilities") | .value // "0"')

echo "📈 New Coverage        : ${NEW_COVERAGE}%"
echo "🐞 New Bugs            : ${NEW_BUGS}"
echo "🔐 New Vulnerabilities : ${NEW_VULNS}"

FAILED=0

if (( $(echo "$NEW_COVERAGE < $MIN_NEW_COVERAGE" | bc -l) )); then
  echo "❌ Coverage on New Code < ${MIN_NEW_COVERAGE}%"
  FAILED=1
fi

if [ "$NEW_BUGS" -gt "$MAX_NEW_BUGS" ]; then
  echo "❌ New Bugs detected"
  FAILED=1
fi

if [ "$NEW_VULNS" -gt "$MAX_NEW_VULNS" ]; then
  echo "❌ New Vulnerabilities detected"
  FAILED=1
fi

if [ "$FAILED" -eq 1 ]; then
  echo "❌ Gate-1 METRICS CHECK FAILED"
  exit 1
fi

echo "✅ Gate-1 METRICS CHECK PASSED"
