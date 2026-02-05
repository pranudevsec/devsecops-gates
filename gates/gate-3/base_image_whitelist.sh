#!/usr/bin/env bash
set -euo pipefail

echo "🐳 Gate-3: Base Image Whitelist"

ALLOWED="alpine|distroless|ubuntu:22.04"

BASE_IMAGE=$(grep -i "^FROM" Dockerfile | head -1 | awk '{print $2}')

echo "$BASE_IMAGE" | grep -E "$ALLOWED" || exit 1

echo "✅ Base image approved"
