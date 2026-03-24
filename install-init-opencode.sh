#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════
# install-init-opencode - Install init-opencode to system
# ═══════════════════════════════════════════════════════════════════

ok()   { echo -e "\033[32m✔\033[0m $*"; }
info() { echo -e "\033[34mℹ\033[0m $*"; }
err()  { echo -e "\033[31m✘\033[0m $*"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SCRIPT="$SCRIPT_DIR/init-opencode.sh"

# --- Detect container runtime ---
if command -v podman &>/dev/null; then
    ENGINE=podman
elif command -v docker &>/dev/null; then
    ENGINE=docker
else
    err "No container runtime found (need docker or podman)"
fi

# --- Check if running as root or in user's PATH ---
if [[ $EUID -eq 0 ]]; then
    # Root install: /usr/local/bin or /sbin
    TARGET_DIR="/usr/local/bin"
else
    # User install: ~/.local/bin
    TARGET_DIR="$HOME/.local/bin"
fi

mkdir -p "$TARGET_DIR"

# --- Copy script ---
cp "$INIT_SCRIPT" "$TARGET_DIR/init-opencode"
chmod +x "$TARGET_DIR/init-opencode"

ok "Installed to $TARGET_DIR/init-opencode"

# --- Add to PATH if needed ---
if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
    if [[ $EUID -eq 0 ]]; then
        ok "Added to PATH (system-wide)"
    else
        info "Add this to your shell config:"
        echo ""
        echo "    export PATH=\"\$PATH:$TARGET_DIR\""
        echo ""
    fi
fi

ok "Installation complete!"
info "Run: init-opencode"
