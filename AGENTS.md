# Environment Context
You are running inside an Alpine Linux container.

## Environment Details
- OS: Alpine Linux (Docker container)
- Working directory: /workspace
- Temporary (you can install tools to be able to do things)

---

# Project Overview
This is the opencode-compose project - a Docker/Podman Compose configuration for running OpenCode instances. It provides shell scripts to bootstrap and manage OpenCode environments.

---

# Build/Lint/Test Commands

## Running the Project
```bash
# Start OpenCode using docker/podman compose
./start-single.sh

# Initialize a new OpenCode environment
./init-opencode.sh

# Install init-opencode to system
./install-init-opencode.sh

# Setup agency agents
./setup-scripts/the-agency.sh
```

## Linting Shell Scripts
```bash
# Install shellcheck
apk add shellcheck

# Lint all shell scripts
shellcheck init-opencode.sh install-init-opencode.sh start-single.sh setup-scripts/*.sh

# Lint a single script
shellcheck init-opencode.sh
```

## Testing
There are no automated tests in this project. Manual testing is done by running the scripts and verifying expected behavior.

---

# Code Style Guidelines

## Shell Script Conventions

### Shebang and Interpreter
- Use `#!/usr/bin/env bash` for all bash scripts
- Scripts must be POSIX-compliant where possible

### Error Handling
- Always use `set -euo pipefail` at the top of every script
- Use custom exit functions:
  ```bash
  ok()   { echo -e "\033[32m✔\033[0m $*"; }
  info() { echo -e "\033[34mℹ\033[0m $*"; }
  err()  { echo -e "\033[31m✘\033[0m $*"; exit 1; }
  ```

### Variables
- Use uppercase for constants, lowercase for variables
- Always quote variables: `"$VAR"` not `$VAR`
- Use `${VAR}` syntax for clarity
- Declare constants with `readonly`:
  ```bash
  readonly CONSTANT_VALUE="something"
  ```

### Functions
- Use `function_name()` syntax (not `function function_name`)
- Declare functions before use
- Use local variables inside functions:
  ```bash
  function my_func() {
      local var="$1"
      ...
  }
  ```

### Conditionals
- Use `[[ ]]` for bash conditionals (not `[ ]`)
- Quote strings in conditionals: `[[ -f "$FILE" ]]`
- Use `=~` for regex matching

### Loops
- Use `for` loops with proper quoting
- Use `shopt -s nullglob` when globbing files
- Always handle empty arrays

### Paths
- Resolve script directory relative to script location:
  ```bash
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ```
- Use absolute paths when possible

### Exit Codes
- Exit 0 for success
- Exit 1 for general errors
- Use specific exit codes for different error types when needed

### Comments
- Use comments to explain complex logic
- Add section headers:
  ```bash
  # ═══════════════════════════════════════════════════════════════════
  # Section Title
  # ═══════════════════════════════════════════════════════════════════
  ```
- Keep comments concise and meaningful

---

# Docker/Podman Conventions

### Runtime Detection
Detect container runtime in this order:
```bash
if command -v podman &>/dev/null; then
    ENGINE=podman
elif command -v docker &>/dev/null; then
    ENGINE=docker
else
    err "No container runtime found (need docker or podman)"
fi
```

### Compose File
- Use `docker-compose.yml` (not `.yaml`)
- Include proper volume mounts for workspace
- Use `network_mode: bridge`
- Set `restart: "no"` for development

---

# File Structure
```
opencode-compose/
├── AGENTS.md                    # This file
├── README.md                    # Project overview
├── docker-compose.yml           # Container configuration
├── opencode.json                # OpenCode model config
├── init-opencode.sh             # Bootstrap script
├── install-init-opencode.sh     # System installation script
├── start-single.sh              # Run OpenCode
└── setup-scripts/
    └── the-agency.sh            # Agency agents setup
```

---

# Dependencies
- bash (>= 4.0)
- docker OR podman
- git
- unzip (for setup scripts)
- curl (for downloading)

---

# General Guidelines
- Keep scripts under 200 lines when possible
- Use meaningful variable and function names
- Handle edge cases (empty directories, missing files, etc.)
- Provide helpful error messages with context
- Use color output for user feedback (green for success, blue for info, red for errors)
