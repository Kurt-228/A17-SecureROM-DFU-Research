# Analysis baseline

## Confirmed

- Both inputs are raw 524288-byte images.
- Their SHA-256 values are pinned in `checksums/firmware.sha256`.
- `images/brom2014` contains AArch64 pointer-authentication instructions.
- Fresh disassembly at offsets `0x1ddac` and `0x1ddc0` yields `BRAAZ`.

## Corrected legacy claim

The old report treated `BRAAZ` as an unauthenticated indirect branch and used
that premise to support an RCE narrative. That interpretation is wrong:
`BRAAZ` authenticates the target with key A and a zero modifier before
branching. No target-pointer PAC bypass is demonstrated by the supplied
material.

## Not established

- Host control over the proposed parser state or callback targets.
- A reachable out-of-bounds read/write primitive.
- Runtime allocator and SRAM placement needed by the proposed chain.
- A stale-state information leak.
- Controlled program counter, code execution, or jailbreak impact.
- Behavior on live A17 hardware.

Treat old names, structures, and exploitability claims as hypotheses until they
are independently reproduced in the clean project.

