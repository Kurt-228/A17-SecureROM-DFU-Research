#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

sha256sum --check checksums/firmware.sha256

for image in images/brom20024 images/brom2014; do
    size="$(stat --format='%s' "$image")"
    if [[ "$size" != "524288" ]]; then
        printf 'unexpected size for %s: %s bytes\n' "$image" "$size" >&2
        exit 1
    fi

    if ! rg --text --quiet --fixed-strings 'SecureROM' "$image"; then
        printf 'SecureROM marker missing from %s\n' "$image" >&2
        exit 1
    fi
done

printf 'firmware verification: PASS\n'

