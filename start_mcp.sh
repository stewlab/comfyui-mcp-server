#!/usr/bin/env bash
# Start ComfyUI MCP Server
# Prerequisites:
#   1. ComfyUI running on http://127.0.0.1:8188 (run: nix run ~/.config/pilo/flake/devshells/comfyui)

set -euo pipefail

MCP_DIR="/home/thom/Desktop/workspace-neo/submodules/stewlab/ai/comfyui-mcp-server"
CONFIG_DIR="${HOME}/.config/comfy-mcp"
PORT=9000

# Parse arguments
WORKFLOW_DIR=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --workflow-dir)
            WORKFLOW_DIR="$2"
            shift 2
            ;;
        --workflow-dir=*)
            WORKFLOW_DIR="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: start_mcp.sh [--workflow-dir PATH]"
            exit 1
            ;;
    esac
done

# Export workflow dir for server.py if provided
if [[ -n "${WORKFLOW_DIR}" ]]; then
    export COMFY_MCP_WORKFLOW_DIR="${WORKFLOW_DIR}"
fi

# Create config directory if it doesn't exist
mkdir -p "${CONFIG_DIR}"

# Create default config if it doesn't exist
if [[ ! -f "${CONFIG_DIR}/config.json" ]]; then
    cat > "${CONFIG_DIR}/config.json" << 'EOF'
{
  "comfyui_url": "http://localhost:8188",
  "output_dir": "/home/thom/.local/share/ai-media/comfyui",
  "defaults": {
    "image": {
      "model": "flux1-schnell-fp8.safetensors",
      "width": 1024,
      "height": 1024,
      "steps": 30,
      "cfg": 7.0,
      "sampler_name": "euler",
      "scheduler": "simple",
      "negative_prompt": "text, watermark, low quality, blurry"
    },
    "audio": {
      "model": "stable-audio-open-1.0.safetensors",
      "steps": 50,
      "cfg": 5.0,
      "sampler_name": "euler",
      "scheduler": "simple"
    },
    "video": {
      "width": 1280,
      "height": 720,
      "steps": 20,
      "cfg": 8.0,
      "sampler_name": "euler",
      "scheduler": "normal"
    }
  }
}
EOF
    echo "Created default config at ${CONFIG_DIR}/config.json"
fi

# Check if ComfyUI is running
if ! curl -s "http://127.0.0.1:8188/system_stats" > /dev/null 2>&1; then
    echo "WARNING: ComfyUI doesn't appear to be running on port 8188"
    echo "Start it with: run-comfy"
    echo "Continuing anyway..."
fi

cd "${MCP_DIR}"

# Start the MCP server via the devshell
echo "Starting ComfyUI MCP Server on http://[IP_ADDRESS]:${PORT}/mcp"
echo "Config: ${CONFIG_DIR}/config.json"
echo "Workflows: ${COMFY_MCP_WORKFLOW_DIR:-${MCP_DIR}/workflows}"
echo ""
echo "Press Ctrl+C to stop"
echo ""

nix develop ~/.config/pilo/flake/devshells/comfyui-mcp --command python3 server.py
