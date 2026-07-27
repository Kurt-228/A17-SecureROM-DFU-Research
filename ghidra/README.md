# Ghidra workspace

Tested host components:

- Ghidra `12.1.2`
- OpenJDK `21`
- Ghidra MCP `5.14.2`
- Processor language `AARCH64:LE:64:v8A:default`
- Raw ROM mapping `0x00000000`–`0x0007ffff`

## Bootstrap

```bash
./scripts/verify-firmware.sh
./scripts/bootstrap-ghidra.sh
```

This creates `work/ghidra/A17SecureROM.gpr` and imports both images as raw
AArch64 little-endian binaries with their memory blocks mapped to
`0x00000000`–`0x0007ffff`. This is intentional: mapping the file itself at
`0xfc000000` makes Ghidra double-add the base to PC-relative references. A
post-import script verifies both the memory range and the anchor instruction
`0x1dda0: ADRP ..., 0xfc03c000`. The local Ghidra database is deliberately not
versioned.

## GUI and MCP

Codex is configured to run `scripts/codex-ghidra-mcp.sh` as its stdio MCP
server. The wrapper starts Ghidra `5.14.2` headless on
`127.0.0.1:8089`, opens `/brom2014`, waits for a healthy REST API, and then
executes the MCP bridge. Program selectors are mandatory, preventing calls from
silently hitting the wrong open binary.

Check the running server:

```bash
./scripts/check-ghidra-mcp.sh
```

Stop the managed headless server:

```bash
./scripts/stop-ghidra-mcp.sh
```

For GUI work, stop the headless server first, start Ghidra, and open
`work/ghidra/A17SecureROM.gpr`. If necessary, enable `GhidraMCP` under
`File > Configure > Configure All Plugins`, then use
`Tools > GhidraMCP > Start MCP Server`.

The plugin listens only on localhost by default. The Codex MCP bridge is a
stdio process and connects to the plugin via its Unix socket or
`http://127.0.0.1:8089`.
