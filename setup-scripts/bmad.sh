#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
URL="https://github.com/bmad-code-org/BMAD-METHOD/archive/refs/heads/main.zip"
TEMP_DIR="$SCRIPT_DIR/temp"
OLD_DIR="$SCRIPT_DIR/old"
TEMP_ZIP="$TEMP_DIR/bmad-main.zip"
OLD_ZIP="$OLD_DIR/bmad-main.zip"
DEST="$SCRIPT_DIR/../.opencode/skills"
EXTRACT_DIR="$TEMP_DIR/extracted"

ok()   { echo -e "\033[32m✔ $*\033[0m"; }
info() { echo -e "\033[34mℹ $*\033[0m"; }
err()  { echo -e "\033[31m✘ $*\033[0m"; exit 1; }

mkdir -p "$TEMP_DIR" "$OLD_DIR"

info "Downloading BMAD-METHOD..."
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

BMAD_ROOT=$(find "$EXTRACT_DIR" -maxdepth 1 -type d -name "BMAD-METHOD-*" | head -1)
[[ -z "$BMAD_ROOT" ]] && err "Could not find extracted BMAD-METHOD directory."

# --- Copy skill folders into dest ---
# Structure: src/core-skills/<skill-name>/ and src/bmm-skills/<phase>/<skill-name>/
mkdir -p "$DEST"
count=0

# core-skills: direct children are skill folders
for skill_folder in "$BMAD_ROOT/src/core-skills"/*/; do
  [[ -d "$skill_folder" ]] || continue
  [[ -f "$skill_folder/SKILL.md" ]] || continue
  skill_name="$(basename "$skill_folder")"
  cp -r "$skill_folder" "$DEST/$skill_name"
  (( count++ )) || true
done

# bmm-skills: one level of phase subfolders, then skill folders
for phase_dir in "$BMAD_ROOT/src/bmm-skills"/*/; do
  [[ -d "$phase_dir" ]] || continue
  for skill_folder in "$phase_dir"*/; do
    [[ -d "$skill_folder" ]] || continue
    [[ -f "$skill_folder/SKILL.md" ]] || continue
    skill_name="$(basename "$skill_folder")"
    cp -r "$skill_folder" "$DEST/$skill_name"
    (( count++ )) || true
  done
done

[[ $count -eq 0 ]] && err "No skill folders found!"
ok "$count skills installed → $DEST"

# --- Update cache ---
cp "$TEMP_ZIP" "$OLD_ZIP"
rm -rf "$EXTRACT_DIR" "$TEMP_ZIP"
ok "Cache updated."
