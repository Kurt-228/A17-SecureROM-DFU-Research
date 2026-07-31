#!/usr/bin/env python3
"""Produce a deterministic raw comparison of the two SecureROM images."""

from __future__ import annotations

import argparse
import hashlib
import json
from collections import Counter
from pathlib import Path


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def printable_strings(data: bytes, minimum: int = 4) -> set[str]:
    strings: set[str] = set()
    start = 0
    for end, value in enumerate(data + b"\x00"):
        if 0x20 <= value <= 0x7E:
            continue
        if end - start >= minimum:
            strings.add(data[start:end].decode("ascii"))
        start = end + 1
    return strings


def diff_runs(old: bytes, new: bytes) -> list[tuple[int, int]]:
    runs: list[tuple[int, int]] = []
    run_start: int | None = None
    for offset, (old_byte, new_byte) in enumerate(zip(old, new)):
        if old_byte != new_byte and run_start is None:
            run_start = offset
        elif old_byte == new_byte and run_start is not None:
            runs.append((run_start, offset - 1))
            run_start = None
    if run_start is not None:
        runs.append((run_start, min(len(old), len(new)) - 1))
    return runs


def display_path(path: Path, repo_root: Path) -> str:
    try:
        return path.resolve().relative_to(repo_root).as_posix()
    except ValueError:
        return str(path)


def main() -> int:
    repo_root = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--old", type=Path, default=repo_root / "images/brom20024")
    parser.add_argument("--new", type=Path, default=repo_root / "images/brom2014")
    parser.add_argument("--page-size", type=int, default=0x1000)
    parser.add_argument("--top-pages", type=int, default=10)
    args = parser.parse_args()

    old = args.old.read_bytes()
    new = args.new.read_bytes()
    if len(old) != len(new):
        raise SystemExit(f"image sizes differ: {len(old)} != {len(new)}")

    changed_offsets = [
        offset for offset, pair in enumerate(zip(old, new)) if pair[0] != pair[1]
    ]
    page_counts = Counter(offset // args.page_size for offset in changed_offsets)
    old_strings = printable_strings(old)
    new_strings = printable_strings(new)
    runs = diff_runs(old, new)

    report = {
        "old": {
            "path": display_path(args.old, repo_root),
            "size": len(old),
            "sha256": sha256(old),
        },
        "new": {
            "path": display_path(args.new, repo_root),
            "size": len(new),
            "sha256": sha256(new),
        },
        "different_bytes": len(changed_offsets),
        "different_percent": round(100 * len(changed_offsets) / len(old), 6),
        "different_runs": len(runs),
        "first_difference": f"0x{changed_offsets[0]:x}" if changed_offsets else None,
        "last_difference": f"0x{changed_offsets[-1]:x}" if changed_offsets else None,
        "top_changed_pages": [
            {"start": f"0x{page * args.page_size:x}", "different_bytes": count}
            for page, count in page_counts.most_common(args.top_pages)
        ],
        "ascii_only_in_old": sorted(old_strings - new_strings),
        "ascii_only_in_new": sorted(new_strings - old_strings),
    }
    print(json.dumps(report, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
