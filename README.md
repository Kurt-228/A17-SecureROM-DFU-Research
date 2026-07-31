# A17 SecureROM DFU Research

Clean reverse-engineering workspace for two raw 512 KiB A17 SecureROM images.

## Status

This repository contains research inputs and reproducible environment setup. It
does **not** contain a demonstrated vulnerability, PAC bypass, code-execution
primitive, or jailbreak chain.

The legacy report and broken generated Ghidra project were moved to a separate
rollback archive and are intentionally not part of this repository.

## Inputs

| File | Size | SHA-256 |
| --- | ---: | --- |
| `images/brom20024` | 524288 bytes | `84a94cde9ecd8aae22390225f31c2d394eca05a7be836f010ee5b429992029b6` |
| `images/brom2014` | 524288 bytes | `f10798e0ea66722aa272cf697678154ea18d79cfa03f1db567dc2564d2ffa55f` |

Verify them before analysis:

```bash
./scripts/verify-firmware.sh
```

Create a fresh local Ghidra project:

```bash
./scripts/bootstrap-ghidra.sh
```

The generated project and analysis state live under `work/` and are excluded
from Git. See [ghidra/README.md](ghidra/README.md) for the local workflow and
MCP startup.

## Research baseline

Read [docs/ANALYSIS_BASELINE.md](docs/ANALYSIS_BASELINE.md) before relying on
claims inherited from the old bundle. Acquisition provenance and
redistribution status are not independently established; see
[docs/PROVENANCE.md](docs/PROVENANCE.md).

The current reproducible comparison and bounded reverse-engineering findings
are recorded in [docs/BINARY_COMPARISON.md](docs/BINARY_COMPARISON.md). Generate
the raw JSON evidence with `python3 scripts/compare-firmware.py`.

