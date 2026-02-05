#!/usr/bin/env bash
set -euo pipefail

echo "📦 Gate-3: Provenance / SLSA"

cosign verify-attestation "$IMAGE_NAME" \
  --type slsaprovenance | grep -q "SLSA"

echo "✅ SLSA provenance verified"
