#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
project="$repo_root/work/ghidra/A17SecureROM.gpr"
server_log="$repo_root/work/logs/ghidra-mcp-headless.log"
pid_file="$repo_root/work/ghidra-mcp-headless.pid"
health_url="http://127.0.0.1:8089/check_connection"
bridge="/opt/ghidra-mcp/bridge_mcp_ghidra.py"
launcher="/opt/ghidra/support/launch.sh"

if [[ ! -e "$project" ]]; then
    "$repo_root/scripts/bootstrap-ghidra.sh" >&2
fi

if ! curl --silent --fail --max-time 2 "$health_url" >/dev/null; then
    if ss -ltn '( sport = :8089 )' | tail -n +2 | rg --quiet .; then
        printf 'port 8089 is occupied by a non-Ghidra-MCP service\n' >&2
        exit 1
    fi

    mkdir -p "$(dirname -- "$server_log")"
    nohup "$launcher" fg jdk GhidraMCPHeadless 4G "" \
        com.xebyte.headless.GhidraMCPHeadlessServer \
        --bind 127.0.0.1 \
        --port 8089 \
        --project "$project" \
        --program /brom2014 \
        </dev/null >>"$server_log" 2>&1 &
    launcher_pid=$!

    for _ in {1..120}; do
        if curl --silent --fail --max-time 2 "$health_url" >/dev/null; then
            break
        fi
        if ! kill -0 "$launcher_pid" 2>/dev/null; then
            printf 'Ghidra MCP headless server exited during startup\n' >&2
            tail -n 80 "$server_log" >&2
            exit 1
        fi
        sleep 0.5
    done

    if ! curl --silent --fail --max-time 2 "$health_url" >/dev/null; then
        printf 'Ghidra MCP headless server did not become healthy\n' >&2
        tail -n 80 "$server_log" >&2
        exit 1
    fi

    server_pid="$(pgrep -P "$launcher_pid" -x java | head -n 1)"
    if [[ -z "$server_pid" ]]; then
        printf 'could not resolve the Ghidra MCP Java process\n' >&2
        exit 1
    fi
    printf '%s\n' "$server_pid" >"$pid_file"
fi

exec /usr/bin/python "$bridge" --no-lazy
