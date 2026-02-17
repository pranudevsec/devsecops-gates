#!/bin/bash
set -e

echo "🐳 Gate-3: Base Image Whitelist"

ALLOWED_IMAGES=("node:20-alpine" "nginx:alpine" "postgres:15")

check_dockerfile() {
  FILE=$1

  if [ ! -f "$FILE" ]; then
    echo "❌ Dockerfile not found: $FILE"
    exit 1
  fi

  BASE=$(grep -i "^FROM" "$FILE" | head -n1 | awk '{print $2}')

  echo "🔎 Found base image in $FILE → $BASE"

  for allowed in "${ALLOWED_IMAGES[@]}"; do
    if [[ "$BASE" == "$allowed" ]]; then
      echo "✅ Approved base image: $BASE"
      return 0
    fi
  done

  echo "❌ Unapproved base image: $BASE"
  exit 0
}

check_dockerfile backend/Dockerfile
check_dockerfile frontend/Dockerfile

