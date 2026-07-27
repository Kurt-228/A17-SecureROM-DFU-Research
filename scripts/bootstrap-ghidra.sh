#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
project_dir="$repo_root/work/ghidra"
project_name="A17SecureROM"
analyzer="/opt/ghidra/support/analyzeHeadless"
marker_dir="$repo_root/work/verification"
verification_token="$(date -u +'%Y%m%dT%H%M%SZ')-$$"
run_log="$repo_root/work/logs/analyzeHeadless-$verification_token.log"

"$repo_root/scripts/verify-firmware.sh"

if [[ ! -x "$analyzer" ]]; then
    printf 'Ghidra headless analyzer not found: %s\n' "$analyzer" >&2
    exit 1
fi

mkdir -p "$project_dir" "$marker_dir" "$(dirname -- "$run_log")"

if [[ -e "$project_dir/$project_name.gpr" ]]; then
    for program in brom20024 brom2014; do
        "$analyzer" "$project_dir" "$project_name" \
            -process "$program" \
            -noanalysis \
            -scriptPath "$repo_root/ghidra/scripts" \
            -postScript VerifyImageBase.java "$marker_dir" "$verification_token" \
            -log "$run_log"
    done
else
    "$analyzer" "$project_dir" "$project_name" \
        -import "$repo_root/images/brom20024" "$repo_root/images/brom2014" \
        -loader BinaryLoader \
        -loader-baseAddr 0x0 \
        -loader-blockName SecureROM \
        -processor AARCH64:LE:64:v8A \
        -cspec default \
        -analysisTimeoutPerFile 300 \
        -max-cpu 4 \
        -scriptPath "$repo_root/ghidra/scripts" \
        -postScript VerifyImageBase.java "$marker_dir" "$verification_token" \
        -log "$run_log"
fi

test -e "$project_dir/$project_name.gpr"

for program in brom20024 brom2014; do
    marker="$marker_dir/$program.mapping"
    expected="$verification_token $program 00000000 0007ffff adrp 0xfc03c000"
    if [[ ! -f "$marker" || "$(<"$marker")" != "$expected" ]]; then
        printf 'Ghidra mapping verification failed for %s\n' "$program" >&2
        exit 1
    fi
done

printf 'Ghidra bootstrap: PASS (%s)\n' "$project_dir/$project_name.gpr"
