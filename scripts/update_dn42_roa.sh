#!/usr/bin/env bash
set -e

# The directory of the script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
# The repository root
REPO_ROOT=$(git rev-parse --show-toplevel)

# The file to update
FILE_TO_UPDATE="$REPO_ROOT/assets/dn42/dn42_roa_bird2_6.conf"
# The URL to download from
URL="https://dn42.burble.com/roa/dn42_roa_bird2_6.conf"

echo "Downloading latest dn42_roa_bird2_6.conf from $URL"
curl -sS --fail -o "$FILE_TO_UPDATE" "$URL"

cd "$REPO_ROOT"

# Check if there are changes
if ! git diff --quiet "$FILE_TO_UPDATE"; then
  echo "File has been updated, committing changes."
  git config --global user.name 'github-actions[bot]'
  git config --global user.email 'github-actions[bot]@users.noreply.github.com'
  git add "$FILE_TO_UPDATE"
  git commit -m "auto update: dn42 roa"
  git push "https://x-access-token:${GH_TOKEN}@github.com/${REPO_SLUG}.git"
else
  echo "No changes to commit."
fi
