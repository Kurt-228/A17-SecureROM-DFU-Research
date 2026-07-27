#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
project_dir="$repo_root/work/ghidra"
project_name="A17SecureROM"
analyzer="/opt/ghidra/support/analyzeHeadless"

"$repo_root/scripts/verify-firmware.sh"

if [[ ! -x "$analyzer" ]]; then
    printf 'Ghidra headless analyzer not found: %s\n' "$analyzer" >&2
    exit 1
fi

mkdir -p "$project_dir"

if [[ -e "$project_dir/$project_name.gpr" ]]; then
    printf 'Ghidra project already exists: %s\n' "$project_dir/$project_name.gpr"
    exit 0
fi

"$analyzer" "$project_dir" "$project_name" \
    -import "$repo_root/images/brom20024" "$repo_root/images/brom2014" \
    -processor AARCH64:LE:64:v8A \
    -cspec default \
    -analysisTimeoutPerFile 300 \
    -max-cpu 4 \
    -log "$repo_root/work/analyzeHeadless.log"

test -e "$project_dir/$project_name.gpr"
printf 'Ghidra bootstrap: PASS (%s)\n' "$project_dir/$project_name.gpr"

