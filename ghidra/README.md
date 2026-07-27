# Ghidra workspace

Tested host components:

- Ghidra `12.1.2`
- OpenJDK `21`
- Ghidra MCP `5.14.2`
- Processor language `AARCH64:LE:64:v8A:default`

## Bootstrap

```bash
./scripts/verify-firmware.sh
./scripts/bootstrap-ghidra.sh
```

This creates `work/ghidra/A17SecureROM.gpr` and imports both images as raw
AArch64 little-endian binaries. The local Ghidra database is deliberately not
versioned.

## GUI and MCP

1. Start Ghidra and open `work/ghidra/A17SecureROM.gpr`.
2. Open either program in CodeBrowser.
3. If necessary, enable `GhidraMCP` under
   `File > Configure > Configure All Plugins`.
4. Start it with `Tools > GhidraMCP > Start MCP Server`.
5. Check the plugin and bridge with:

   ```bash
   ./scripts/check-ghidra-mcp.sh
   ```

The plugin listens only on localhost by default. The Codex MCP bridge is a
stdio process and connects to the plugin via its Unix socket or
`http://127.0.0.1:8089`.

