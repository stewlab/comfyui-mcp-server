#!/usr/bin/env bash
# Stop ComfyUI MCP Server

set -euo pipefail

PORT=9000

# Find and kill the MCP server process
PID=$(lsof -ti:${PORT} 2>/dev/null || true)

if [[ -n "${PID}" ]]; then
    echo "Stopping MCP server (PID: ${PID}) on port ${PORT}..."
    kill "${PID}"
    sleep 1
    # Force kill if still running
    if kill -0 "${PID}" 2>/dev/null; then
        kill -9 "${PID}"
        echo "Force killed"
    fi
    echo "MCP server stopped"
else
    echo "No MCP server found running on port ${PORT}"
fi