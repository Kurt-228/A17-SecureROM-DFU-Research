# Binary Comparison

## Reproduction

Both inputs were imported as raw `AARCH64:LE:64:v8A:default` images at base
address `0x0`. The local Ghidra 12.1.2 project was rebuilt from the tracked
scripts and served through GhidraMCP 6.0.0 on `127.0.0.1`. Run the independent
byte-level comparison with:

```bash
python3 scripts/compare-firmware.py
```

The 512 KiB images differ at 14,099 bytes (2.689171%) in 1,160 contiguous
runs. The first changed byte is at `0x68`, the last at `0x4c140`. Most changes
are concentrated in pages `0x4000`-`0x8fff` (13,930 changed bytes). The only
semantically meaningful ASCII delta is the build string:
`iBoot-8104.0.0.200.24` versus `iBoot-8104.0.0.201.4`; the remaining set
differences are four-byte instruction fragments that happen to be printable.

## Function-Level Triage

Ghidra identified 2,022 functions in `brom20024` and 2,023 in `brom2014`.
Of the same-address functions, 1,921 have the same hash and 16 have changed
hashes. Hash relocation matching explains most address-only differences: 55
functions moved by `-0x30` in the older image without a normalized instruction
change.

The compact semantic-delta set is centered on these newer-image functions:

| Address | Observed role | Evidence-backed change |
| --- | --- | --- |
| `0x4bc8` | IMG4/IM4P parser | Defers optional output writes and retains 64-bit lengths through validation. |
| `0x4e50` | Range/cursor helper | Clears the output on a failing end-before-start check. |
| `0x50cc` | 0x200-byte container loader | Rejects nonzero upper 32 bits before narrowing a parsed length. |
| `0x5528` | IMG4/Memz processing path | Adds a bounds-checked optional 32-bit output write. |
| `0x65c8` | IMG4/Memz dispatcher | Expands a parsed-length local from 32 to 64 bits. |

The older counterparts begin at `0x4bc8`, `0x4e48`, `0x50c4`, `0x5508`, and
`0x65ac`. These observations support a parser-hardening interpretation, not a
vulnerability claim. Input provenance, caller-controlled ranges, live-device
behavior, and an exploitable read/write primitive have not been established.

## PAC and DFU Controls

Independent Capstone 5 verification confirms the identical dispatch sequence
at `0x1dda0`: `adrp`, `ldr x0`, `cbz`, `braaz x0`, `ret`. The indirect branch
therefore authenticates the target with key A and a zero modifier.

The `rsm-usb`/`ta_dfu` lifecycle functions at `0x27f38` and `0x29b04` are
instruction-equivalent after normalizing relocated helper targets. The current
delta is in IMG4/Memz parsing and length propagation; no changed DFU transport
state machine or PAC bypass was found.
