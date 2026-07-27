#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
pid_file="$repo_root/work/ghidra-mcp-headless.pid"

if [[ ! -f "$pid_file" ]]; then
    printf 'no managed Ghidra MCP PID file found\n'
    exit 0
fi

server_pid="$(<"$pid_file")"
if [[ ! "$server_pid" =~ ^[0-9]+$ ]]; then
    printf 'invalid PID file: %s\n' "$pid_file" >&2
    exit 1
fi

if kill -0 "$server_pid" 2>/dev/null; then
    kill "$server_pid"
    for _ in {1..40}; do
        if ! kill -0 "$server_pid" 2>/dev/null; then
            break
        fi
        sleep 0.25
    done
fi

if kill -0 "$server_pid" 2>/dev/null; then
    printf 'Ghidra MCP process %s did not stop cleanly\n' "$server_pid" >&2
    exit 1
fi

rm -- "$pid_file"
printf 'Ghidra MCP headless server stopped\n'

