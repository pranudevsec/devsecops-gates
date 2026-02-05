#!/usr/bin/env bash
set -euo pipefail

echo "✍️ Gate-3: Image Signature Verification"

cosign verify "$IMAGE_NAME" \
  --certificate-identity-regexp ".*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"

echo "✅ Image signature verified"
