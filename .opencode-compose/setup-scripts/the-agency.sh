#!/bin/bash

set -euo pipefail

# Always resolve paths relative to this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

URL="https://github.com/msitarzewski/agency-agents/archive/refs/heads/main.zip"
TEMP_DIR="$SCRIPT_DIR/temp"
OLD_DIR="$SCRIPT_DIR/old"
TEMP_ZIP="$TEMP_DIR/main.zip"
OLD_ZIP="$OLD_DIR/main.zip"
DEST="$SCRIPT_DIR/../.opencode/agents"   # → test-opencode/.opencode/agents
EXTRACT_DIR="$TEMP_DIR/extracted"

ok()   { echo -e "\033[32m✔ $*\033[0m"; }
info() { echo -e "\033[34mℹ $*\033[0m"; }
err()  { echo -e "\033[31m✘ $*\033[0m"; exit 1; }

mkdir -p "$TEMP_DIR" "$OLD_DIR"

info "Downloading agency-agents..."
curl -sL "$URL" -o "$TEMP_ZIP" || err "Download failed."

# --- Hash check ---
if [[ -f "$OLD_ZIP" ]]; then
  NEW_HASH=$(sha256sum "$TEMP_ZIP" | awk '{print $1}')
  OLD_HASH=$(sha256sum "$OLD_ZIP"  | awk '{print $1}')

  if [[ "$NEW_HASH" == "$OLD_HASH" ]]; then
    ok "Already up-to-date. Nothing to do."
    rm -f "$TEMP_ZIP"
    exit 0
  fi
  info "New version detected, updating..."
else
  info "No previous version found, installing..."
fi

# --- Extract ---
rm -rf "$EXTRACT_DIR"
unzip -q "$TEMP_ZIP" -d "$EXTRACT_DIR"

# Root is agency-agents-main/
AGENTS_ROOT=$(find "$EXTRACT_DIR" -maxdepth 1 -type d -name "agency-agents-*" | head -1)
[[ -z "$AGENTS_ROOT" ]] && err "Could not find extracted agency-agents-main directory."

# --- Copy all .md files recursively (flatten into dest) ---
mkdir -p "$DEST"
count=0
while IFS= read -r -d '' f; do
  cp "$f" "$DEST/"
  (( count++ )) || true
done < <(find "$AGENTS_ROOT" -name "*.md" -not -name "README.md" -print0)

[[ $count -eq 0 ]] && err "No .md files found!"

ok "$count agents installed → $DEST"

# --- Update cache ---
cp "$TEMP_ZIP" "$OLD_ZIP"
rm -rf "$EXTRACT_DIR" "$TEMP_ZIP"
ok "Cache updated."
