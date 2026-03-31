# AGENTS.md - OpenCode Compose Project

This file provides guidance for AI agents operating in this repository.

## Project Overview

OpenCode Compose is a Docker/Podman-based manager for running OpenCode in isolated containers. The repository contains shell scripts, Docker configuration, and agent definition files.

## Environment Context

- **OS**: Alpine Linux (Docker container)
- **Working directory**: `/workspace`
- **Runtime**: Docker/Podman

## Git Workflow

- Always push code to `main` branch
- Before pushing, ensure you are on the correct branch:
  ```
  git checkout main 2>/dev/null || git checkout -b main
  ```
- To push changes:
  ```
  git add .
  git commit -m "your commit message"
  git push origin main
  ```

## Build Commands

### Local Development

```bash
# Start OpenCode container
docker-compose up -d opencode

# Rebuild container
docker-compose build opencode

# View logs
docker-compose logs -f opencode

# Stop container
docker-compose down
```

### Scripts

```bash
# Quick start (runs start-single.sh)
./start-single.sh

# Install init-opencode globally
./install-init-opencode.sh
```

## Lint Commands

```bash
# Lint shell scripts
shellcheck start-single.sh init-opencode.sh install-init-opencode.sh

# YAML validation
yamllint docker-compose.yml

# JSON validation
cat opencode.json | python3 -m json.tool
```

## Testing

This project doesn't have automated tests. Manual testing:

```bash
# Test container starts
docker-compose up -d opencode
docker exec opencode --version

# Test SSH key mount (if configured)
docker exec opencode ls -la ~/.ssh/

# Test init script
./start-single.sh --help
```

## Code Style Guidelines

### Shell Scripts

- Use `#!/bin/bash` (not `#!/bin/sh`)
- Use `set -euo pipefail` for strict error handling
- Add descriptive comments for complex logic
- Use meaningful variable names (lowercase with underscores)
- Quote variables: `"${VARIABLE}"` not `$VARIABLE`
- Use `[[ ]]` for conditionals (not `[ ]`)
- Functions: `function_name()` or `function_name ()`

### Docker Compose

- Use YAML anchors for repeated values
- Comment non-obvious configuration
- Use `z` flag for selinux-compatible volumes
- Specify `restart: "no"` for development services

### General

- 2 space indentation in YAML/shell
- 100 character line limit where reasonable
- No trailing whitespace
- LF line endings (not CRLF)

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Shell scripts | kebab-case | `start-single.sh` |
| Config files | kebab-case | `docker-compose.yml` |
| Variables | SCREAMING_SNAKE (env) | `GROQ_API_KEY` |
| Variables | snake_case (local) | `container_name` |
| Functions | snake_case | `start_container()` |

## Error Handling

- Always check command exit codes: `|| exit 1`
- Use `set -e` to fail on errors
- Provide meaningful error messages
- Log to stderr: `echo "Error: ..." >&2`

## File Structure

```
.
├── AGENTS.md              # This file
├── README.md              # Project documentation
├── docker-compose.yml     # Container configuration
├── opencode.json          # OpenCode model config
├── start-single.sh        # Main entry point
├── init-opencode.sh       # Bootstrap script
├── install-init-opencode.sh  # Installation script
└── .opencode/             # Agent definitions (mounted read-only)
```

## Key Configuration

### opencode.json

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "opencode/minimax-m2.5-free"
}
```

### Volume Mounts

- SSH keys: `/root/.ssh/` (read-only)
- Workspace: `../:/workspace`
- Config: `./opencode.json:/workspace/opencode.json`
- Agents: `./.opencode/:/workspace/.opencode/`

## Common Tasks

### Add New Agent Definition

1. Create file in `.opencode/agents/`
2. Follow naming: `domain-agent-name.md`
3. Mounted automatically on next container start

### Modify Docker Configuration

1. Edit `docker-compose.yml`
2. Rebuild: `docker-compose build opencode`
3. Restart: `docker-compose restart opencode`

### Debug Container Issues

```bash
# Interactive shell in container
docker exec -it opencode /bin/sh

# View environment
docker exec opencode env

# Check running processes
docker exec opencode ps
```