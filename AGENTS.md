# opencode-compose

OpenCode instances manager using Docker/Podman Compose.

## Environment Context

* **OS:** Alpine Linux (Docker container)
* **Working Directory:** `/workspace`
* **State:** Temporary (you can install tools to be able to do things)

---

## Build / Lint / Test Commands

### Running OpenCode

```bash
# Start OpenCode container
./start-single.sh

# Install init-opencode globally
./install-init-opencode.sh

# Then run from any directory
init-opencode
```

### Shell Script Linting

Install shellcheck for static analysis:

```bash
apk add --no-cache shellcheck
```

Run on all shell scripts:

```bash
shellcheck start-single.sh init-opencode.sh install-init-opencode.sh uninstall-init-opencode.sh setup-scripts/*.sh
```

### Testing

There are no automated tests in this project. Manual testing involves:

```bash
# Test start-single.sh
./start-single.sh

# Test init-opencode.sh in a temporary directory
cd /tmp && rm -rf test-opencode && mkdir test-opencode && cd test-opencode && /path/to/init-opencode.sh
```

---

## Code Style Guidelines

### Shell Scripts (Bash)

**Shebang and Header**
- Use `#!/usr/bin/env bash` for portability
- Add brief description comment at top for main scripts
- Use set flags: `set -euo pipefail`

**Formatting**
- Use 4 spaces for indentation (no tabs)
- Maximum line length: 100 characters
- Use blank lines to separate logical sections
- Align related assignments vertically when appropriate

**Naming Conventions**
- Variables: `SCREAMING_SNAKE_CASE` for constants, `lower_snake_case` for variables
- Functions: `ok()`, `info()`, `err()` for status messages
- Scripts: `kebab-case.sh` with descriptive names

**Functions**
```bash
# Status functions (defined at top of scripts)
ok()   { echo -e "\033[32m✔\033[0m $*"; }
info() { echo -e "\033[34mℹ\033[0m $*"; }
err()  { echo -e "\033[31m✘\033[0m $*"; exit 1; }
```

**Error Handling**
- Always use `set -euo pipefail` at script start
- Use `err()` function for fatal errors with `exit 1`
- Check command existence with `command -v foo &>/dev/null`
- Use `${VAR:-default}` for optional variables
- Use `${VAR:?error message}` for required variables

**Imports and External Commands**
- Check for required commands before use
- Support both Docker and Podman as alternatives
- Prefer built-in commands over external dependencies

**Variable Scope**
- Use local variables in functions: `local var=value`
- Use uppercase for environment variables: `${HOME}`, `${PWD}`
- Quote variables to handle spaces: `"$VAR"`

**Conditionals**
- Use `[[ ]]` for tests (not `[ ]`)
- Use `=~` for regex matching
- Always quote string variables in tests

**Command Substitution**
- Use `$(command)` over backticks `` `command` ``

---

## Git Workflow

* **Use SSH for GIT**
* **Verify Current Branch:** Before making changes:
    ```bash
    git status
    git branch --show-current
    ```
* **Branching Strategy:**
    * Default: Use `main` branch for minor updates
    * Create new branch for significant features
* **Branch Preparation:**
    ```bash
    git checkout main 2>/dev/null || git checkout -b main
    git checkout -b <branch-name>
    ```
* **Committing:**
    ```bash
    git add .
    git commit -m "your commit message"
    git push origin <branch-name>
    ```

---

## Configuration

Edit `opencode.json` to change the model:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "opencode/minimax-m2.5-free"
}
```

Environment variables:
- `GROQ_API_KEY` - Set your Groq API key (optional)

---

## Scripts Reference

| Script | Description |
|--------|-------------|
| `start-single.sh` | Start OpenCode container |
| `init-opencode.sh` | Bootstrap new OpenCode environment |
| `install-init-opencode.sh` | Install init-opencode to system |
| `setup-scripts/the-agency.sh` | Setup agency agents |
