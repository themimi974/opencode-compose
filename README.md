# opencode-compose

OpenCode instances manager using Docker/Podman Compose.

## Quick Start

```bash
# Clone this repository
git clone https://github.com/themimi974/opencode-compose.git
cd opencode-compose

# Run OpenCode
./start-single.sh
```

## Prerequisites

- Docker OR Podman
- Git

## Installation

### Option 1: Run directly

```bash
./start-single.sh
```

### Option 2: Install `init-opencode` globally

```bash
./install-init-opencode.sh
```

Then run from any directory:

```bash
init-opencode
```

### Uninstall

```bash
./uninstall-init-opencode.sh
```

## Features

- **Containerized OpenCode** - Run OpenCode in an isolated Docker/Podman container
- **SSH key support** - Clone private repos by mounting SSH keys
- **Config sync** - Sync global OpenCode config into project
- **Agency agents** - Optional setup for agency-agents

## Scripts

| Script | Description |
|--------|-------------|
| `start-single.sh` | Start OpenCode container |
| `init-opencode.sh` | Bootstrap new OpenCode environment |
| `install-init-opencode.sh` | Install init-opencode to system |
| `uninstall-init-opencode.sh` | Uninstall init-opencode from system |
| `setup-scripts/the-agency.sh` | Setup agency agents |

## Configuration

### OpenCode Model

Edit `opencode.json` to change the model:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "opencode/minimax-m2.5-free"
}
```

### Environment Variables

- `GROQ_API_KEY` - Set your Groq API key (optional)

## License

MIT

## Creator

themimi974
