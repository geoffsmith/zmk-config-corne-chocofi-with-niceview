#!/usr/bin/env bash
set -euo pipefail

OWNER="geoffsmith"
REPO="zmk-config-corne-chocofi-with-niceview"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
source "${SCRIPT_DIR}/.env"

api() {
  curl -sfL \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com$1"
}

# Get latest non-expired artifact
artifact_id=$(
  api "/repos/$OWNER/$REPO/actions/artifacts?per_page=100" \
  | jq '.artifacts
        | map(select(.expired == false))
        | sort_by(.created_at)
        | last
        | .id'
)

if [ -z "$artifact_id" ] || [ "$artifact_id" = "null" ]; then
  echo "No valid artifacts found" >&2
  exit 1
fi

echo "Latest artifact id: $artifact_id"

# Download it
curl -sfL \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$artifact_id/zip" \
  -o latest-artifact.zip

echo "Saved to latest-artifact.zip"
