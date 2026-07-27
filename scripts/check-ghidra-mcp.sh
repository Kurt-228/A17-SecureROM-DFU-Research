#!/usr/bin/env bash
set -euo pipefail

bridge="/opt/ghidra-mcp/bridge_mcp_ghidra.py"
extension_root="${XDG_CONFIG_HOME:-$HOME/.config}/ghidra/ghidra_12.1.2_DEV/Extensions/GhidraMCP"
extension_jar="$extension_root/lib/GhidraMCP-5.14.2.jar"

test -f "$bridge"
test -f "$extension_jar"
python "$bridge" --help >/dev/null

if curl --silent --show-error --fail --max-time 3 \
    http://127.0.0.1:8089/check_connection; then
    printf '\nGhidra MCP health check: PASS\n'
    exit 0
fi

printf '\nGhidra MCP is installed, but the CodeBrowser plugin is not listening.\n' >&2
printf 'Open a program and use Tools > GhidraMCP > Start MCP Server.\n' >&2
exit 2

