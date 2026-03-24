#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════
# init-opencode - Bootstrap OpenCode environment
# ═══════════════════════════════════════════════════════════════════

ok()   { echo -e "\033[32m✔\033[0m $*"; }
info() { echo -e "\033[34mℹ\033[0m $*"; }
err()  { echo -e "\033[31m✘\033[0m $*"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_DIR="$SCRIPT_DIR/.opencode-compose"

# --- Placeholder repo (to be implemented) ---
PLACEHOLDER_REPO="https://github.com/themimi974/opencode-docker-compose.git"

# ═══════════════════════════════════════════════════════════════════
# Step 1: Check if .opencode-compose exists
# ═══════════════════════════════════════════════════════════════════

if [[ -d "$OPENCODE_DIR" ]]; then
    info ".opencode-compose/ already exists in $(pwd)"
    read -p "Reset (re-clone repo)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Removing existing .opencode-compose/..."
        rm -rf "$OPENCODE_DIR"
    else
        ok "Using existing .opencode-compose/"
    fi
fi

# ═══════════════════════════════════════════════════════════════════
# Step 2: Git clone if directory was missing or reset
# ═══════════════════════════════════════════════════════════════════

if [[ ! -d "$OPENCODE_DIR" ]]; then
    info "Cloning placeholder repo..."
    if git clone "$PLACEHOLDER_REPO" "$OPENCODE_DIR" 2>/dev/null; then
        ok "Repository cloned to .opencode-compose/"
    else
        # Fallback: copy local template if clone fails
        info "Clone failed, using local template..."
        LOCAL_TEMPLATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.opencode-compose"
        if [[ -d "$LOCAL_TEMPLATE" ]]; then
            cp -r "$LOCAL_TEMPLATE" "$SCRIPT_DIR/.opencode-compose"
            ok "Local template copied to .opencode-compose/"
        else
            err "No template found. Please create .opencode-compose/ manually."
        fi
    fi
fi

# ═══════════════════════════════════════════════════════════════════
# Step 3: SSH key selection
# ═══════════════════════════════════════════════════════════════════

USER_SSH_DIR="$HOME/.ssh"
SSH_VOLUME=""

if [[ -d "$USER_SSH_DIR" ]]; then
    echo
    info "SSH key options:"
    echo "  1) No SSH (local-only, no git remote)"
    echo "  2) Mount specific key"
    echo "  3) Mount entire ~/.ssh"
    read -p "Choose [1-3]: " -n 1 -r
    echo

    case $REPLY in
        1)
            ok "No SSH configured (local-only mode)"
            ;;
        2)
            # List available keys
            shopt -s nullglob
            keys=("$USER_SSH_DIR"/*)
            if [[ ${#keys[@]} -eq 0 ]]; then
                err "No keys found in $USER_SSH_DIR"
            fi
            
            echo "Available keys:"
            select key in "${keys[@]}"; do
                [[ -n "$key" ]] && break
            done 2>/dev/null
            
            if [[ -n "$key" ]]; then
                KEY_NAME="$(basename "$key")"
                SSH_VOLUME="- $key:/root/.ssh/$KEY_NAME:ro,z"
                ok "Selected key: $KEY_NAME"
            fi
            ;;
        3)
            SSH_VOLUME="- $USER_SSH_DIR:/root/.ssh:ro,z"
            ok "Mounting entire ~/.ssh"
            ;;
        *)
            err "Invalid option"
            ;;
    esac
else
    info "No ~/.ssh directory found, skipping SSH config"
fi

# ═══════════════════════════════════════════════════════════════════
# Step 4: Update docker-compose.yml with SSH volume
# ═══════════════════════════════════════════════════════════════════

COMPOSE_FILE="$OPENCODE_DIR/docker-compose.yml"
if [[ -n "$SSH_VOLUME" ]]; then
    info "Updating docker-compose.yml with SSH volume..."
    
    # Check if volumes section already exists
    if grep -q "^    volumes:" "$COMPOSE_FILE"; then
        # Add SSH volume after existing volumes
        sed -i "/^    volumes:/a\\      $SSH_VOLUME" "$COMPOSE_FILE"
    else
        err "Could not find volumes section in docker-compose.yml"
    fi
    ok "SSH volume added"
fi

# ═══════════════════════════════════════════════════════════════════
# Step 5: Global config detection and sync
# ═══════════════════════════════════════════════════════════════════

GLOBAL_CONFIG="$HOME/.config/opencode/opencode.json"
GLOBAL_DATA="$HOME/.local/share/opencode"
LOCAL_OPENCODE="$OPENCODE_DIR/.opencode"

echo
if [[ -f "$GLOBAL_CONFIG" ]] || [[ -d "$GLOBAL_DATA" ]]; then
    info "Found global OpenCode config/data"
    read -p "Sync global config into project? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$LOCAL_OPENCODE"
        [[ -f "$GLOBAL_CONFIG" ]] && cp "$GLOBAL_CONFIG" "$LOCAL_OPENCODE/" && ok "Copied global config"
        [[ -d "$GLOBAL_DATA" ]] && cp -r "$GLOBAL_DATA"/* "$LOCAL_OPENCODE/" 2>/dev/null && ok "Copied global data"
    fi
else
    info "No global config found at $GLOBAL_CONFIG"
    read -p "Initialize fresh local config? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        mkdir -p "$LOCAL_OPENCODE"
        ok "Created local .opencode/ directory"
    fi
fi

# ═══════════════════════════════════════════════════════════════════
# Step 6: Run start-single.sh
# ═══════════════════════════════════════════════════════════════════

echo
START_SCRIPT="$OPENCODE_DIR/start-single.sh"
if [[ -f "$START_SCRIPT" ]]; then
    info "Launching OpenCode..."
    cd "$OPENCODE_DIR"
    bash "$START_SCRIPT"
else
    err "start-single.sh not found in .opencode-compose/"
fi
