
#!/usr/bin/env bash
set -euo pipefail

URLS=$(grep -RhoE 'https?://[^") ]+' . | sort -u)

for url in $URLS; do
  if ! echo "$url" | grep -qE '^https://([a-zA-Z0-9-]+\.)*army\.mil'; then
    echo "❌ Unauthorized external link: $url"
    exit 1
  fi
done

echo "✅ All external links are whitelisted"
