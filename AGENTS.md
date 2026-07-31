# Repository Guidelines

## Project Structure & Module Organization

- `images/` contains the two 512 KiB SecureROM research inputs. Their expected digests live in `checksums/firmware.sha256`.
- `scripts/` provides Bash entry points for integrity checks, Ghidra project creation, and MCP lifecycle management.
- `ghidra/scripts/VerifyImageBase.java` validates the imported address range and anchor instruction. See `ghidra/README.md` for the tested toolchain and mapping rationale.
- `docs/` records the analysis baseline and acquisition limitations. Keep confirmed observations separate from hypotheses.
- `work/` is generated locally and Git-ignored; never commit Ghidra databases, logs, locks, or MCP PID files.

## Build, Test, and Development Commands

Run commands from the repository root in a Linux/WSL environment. The scripts expect Ghidra under `/opt/ghidra`, Ghidra MCP under `/opt/ghidra-mcp`, OpenJDK 21, Python, `curl`, `rg`, and standard GNU utilities.

```bash
./scripts/verify-firmware.sh     # Check SHA-256, size, and SecureROM markers
./scripts/bootstrap-ghidra.sh    # Create or revalidate work/ghidra/A17SecureROM.gpr
./scripts/check-ghidra-mcp.sh    # Verify the bridge, extension, and REST health endpoint
./scripts/codex-ghidra-mcp.sh    # Start the managed headless server and stdio bridge
./scripts/stop-ghidra-mcp.sh     # Stop only the server tracked by this repository
```

There is no separate build artifact or unit-test framework. A change is not validated until the relevant script exits successfully; mapping changes require a fresh bootstrap check for both images.

## Coding Style & Naming Conventions

Use four-space indentation and preserve LF line endings. Bash scripts must begin with `set -euo pipefail`, quote expansions, derive paths from `repo_root`, and use `snake_case` variables. Name shell entry points with lowercase kebab-case. Java follows Ghidra script conventions: one class per file, `UpperCamelCase` classes, `UPPER_SNAKE_CASE` constants, and explicit failure messages. Keep Markdown factual, concise, and reproducible; include exact addresses, hashes, commands, and observed output where relevant.

## Testing & Research Integrity

Do not silently replace firmware. Add each new input with its own checksum and acquisition note. Treat legacy labels, exploitability claims, and live-device behavior as unverified until reproduced. Keep MCP bound to `127.0.0.1`; do not commit proprietary derived data or credentials.

## Commit & Pull Request Guidelines

Existing history uses short Conventional Commit-style subjects such as `build: add ...` and `chore: establish ...`. Continue with an imperative, lowercase summary and a focused diff. Pull requests should describe the evidence changed, list validation commands and results, link relevant issues, and call out provenance or redistribution concerns. Include screenshots only for Ghidra GUI changes that cannot be shown through logs or scripts.
