#!/usr/bin/env bash
set -euo pipefail

echo "🛡️ Gate-2: CVSS-Based Vulnerability Policy"

REPORT="dependency-check-report.json"
CUSTOM_HTML="gate-2-summary.html"

# --------------------------------------------
# 1️⃣ Ensure Report Exists
# --------------------------------------------
if [ ! -f "$REPORT" ]; then
  echo "❌ Report not found: $REPORT"
  exit 2
fi

# --------------------------------------------
# 2️⃣ Count Vulnerabilities by CVSS Score
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

TOTAL_COUNT=$(jq '
  [.dependencies[].vulnerabilities[]?]
  | length
' "$REPORT")

# --------------------------------------------
# 3️⃣ Print Summary (Console)
# --------------------------------------------

echo "🔎 CVSS Summary:"
echo "Total Vulnerabilities: $TOTAL_COUNT"
echo "Critical (>=9.0): $CRITICAL_COUNT"
echo "High (>=7.0 <9.0): $HIGH_COUNT"
echo "Medium (>=4.0 <7.0): $MEDIUM_COUNT"
echo "Low (>0 <4.0): $LOW_COUNT"

# --------------------------------------------
# 4️⃣ Generate Custom HTML Report
# --------------------------------------------

echo "<html><body>" > $CUSTOM_HTML
echo "<h2>Gate-2 CVSS Summary</h2>" >> $CUSTOM_HTML
echo "<p><strong>Total Vulnerabilities:</strong> $TOTAL_COUNT</p>" >> $CUSTOM_HTML
echo "<p>Critical: $CRITICAL_COUNT</p>" >> $CUSTOM_HTML
echo "<p>High: $HIGH_COUNT</p>" >> $CUSTOM_HTML
echo "<p>Medium: $MEDIUM_COUNT</p>" >> $CUSTOM_HTML
echo "<p>Low: $LOW_COUNT</p>" >> $CUSTOM_HTML

echo "<h3>Vulnerable Files</h3><ul>" >> $CUSTOM_HTML

jq -r '
  .dependencies[]
  | select(.vulnerabilities != null)
  | "<li>\(.fileName) - \(.filePath)</li>"
' "$REPORT" >> $CUSTOM_HTML

echo "</ul>" >> $CUSTOM_HTML

# --------------------------------------------
# 5️⃣ Enforcement Policy
# --------------------------------------------

# 🔴 Critical must be ZERO
if [ "$CRITICAL_COUNT" -ne 0 ]; then
  echo "<h3 style=\"color:red;\">Gate Status: FAILED (Critical Vulnerabilities Found)</h3>" >> $CUSTOM_HTML
  echo "</body></html>" >> $CUSTOM_HTML
  echo "❌ Critical vulnerabilities detected"
  exit 0
fi

# 🟠 High threshold (max allowed = 4)
if [ "$HIGH_COUNT" -gt 4 ]; then
  echo "<h3 style=\"color:red;\">Gate Status: FAILED (High Vulnerabilities Exceeded)</h3>" >> $CUSTOM_HTML
  echo "</body></html>" >> $CUSTOM_HTML
  echo "❌ Too many CVSS >= 7.0 vulnerabilities"
  exit 0
fi

# 🟢 Passed
echo "<h3 style=\"color:green;\">Gate Status: PASSED</h3>" >> $CUSTOM_HTML
echo "</body></html>" >> $CUSTOM_HTML

echo "✅ CVSS policy compliant"

