#!/usr/bin/env bash
set -euo pipefail

echo "🛡️ Gate-2: CVSS-Based Vulnerability Policy"

REPORT="dependency-check-report.json"

# --------------------------------------------
# 1️⃣ Ensure Report Exists
# --------------------------------------------
if [ ! -f "$REPORT" ]; then
  echo "❌ Report not found: $REPORT"
  exit 2
fi

# --------------------------------------------
# 2️⃣ Count Vulnerabilities by CVSS Score
#    - CVSSv3 preferred
#    - fallback to CVSSv2
# --------------------------------------------
CRITICAL_COUNT=$(jq '
  [.dependencies[].vulnerabilities[]?
   | (.cvssv3?.baseScore // .cvssv2?.score // 0)
   | select(. >= 9)] | length
' "$REPORT")

HIGH_COUNT=$(jq '
  [.dependencies[].vulnerabilities[]?
   | (.cvssv3?.baseScore // .cvssv2?.score // 0)
   | select(. >= 7 and . < 9)] | length
' "$REPORT")

MEDIUM_COUNT=$(jq '
  [.dependencies[].vulnerabilities[]?
   | (.cvssv3?.baseScore // .cvssv2?.score // 0)
   | select(. >= 4 and . < 7)] | length
' "$REPORT")

LOW_COUNT=$(jq '
  [.dependencies[].vulnerabilities[]?
   | (.cvssv3?.baseScore // .cvssv2?.score // 0)
   | select(. > 0 and . < 4)] | length
' "$REPORT")


# --------------------------------------------
# 3️⃣ Print Summary (For Jenkins Console)
# --------------------------------------------

echo "🔎 CVSS Summary:"
echo "Total Vulnerabilities: $TOTAL_COUNT"
echo "Critical (>=9.0): $CRITICAL_COUNT"
echo "High (>=7.0 <9.0): $HIGH_COUNT"
echo "Medium (>=4.0 <7.0): $MEDIUM_COUNT"
echo "Low (>0 <4.0): $LOW_COUNT"

# --------------------------------------------
# 4️⃣ Enforcement Policy
# --------------------------------------------

# 🔴 Critical must be ZERO
if [ "$CRITICAL_COUNT" -ne 0 ]; then
  echo "❌ CVSS >= 9.0 vulnerabilities detected"
  exit 1
fi

# 🟠 High threshold (max allowed = 5)
if [ "$HIGH_COUNT" -gt 5 ]; then
  echo "❌ Too many CVSS >= 7.0 vulnerabilities"
  exit 1
fi

# 🟡 Medium & Low → Allowed (Informational)

echo "✅ CVSS policy compliant"

