// Verify the raw SecureROM mapping created by scripts/bootstrap-ghidra.sh.
// @category A17

import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Instruction;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.Locale;

public class VerifyImageBase extends GhidraScript {
    private static final long EXPECTED_BASE = 0x00000000L;
    private static final long EXPECTED_END = 0x0007ffffL;
    private static final long ANCHOR_ADDRESS = 0x0001dda0L;
    private static final String ANCHOR_TARGET = "0xfc03c000";

    @Override
    protected void run() throws Exception {
        String[] args = getScriptArgs();
        if (args.length != 2) {
            throw new IllegalArgumentException(
                "Expected marker directory and verification token");
        }

        Address memoryMin = currentProgram.getMemory().getMinAddress();
        Address memoryMax = currentProgram.getMemory().getMaxAddress();
        Instruction anchor =
            currentProgram.getListing().getInstructionAt(toAddr(ANCHOR_ADDRESS));

        if (memoryMin.getOffset() != EXPECTED_BASE ||
            memoryMax.getOffset() != EXPECTED_END) {
            throw new IllegalStateException(String.format(
                "Unexpected SecureROM mapping: memory=%s-%s",
                memoryMin, memoryMax));
        }

        if (anchor == null) {
            throw new IllegalStateException(
                "Missing anchor instruction at 0x1dda0");
        }

        String mnemonic = anchor.getMnemonicString().toLowerCase(Locale.ROOT);
        String target = anchor.getDefaultOperandRepresentation(1)
            .toLowerCase(Locale.ROOT);
        if (!mnemonic.equals("adrp") || !target.equals(ANCHOR_TARGET)) {
            throw new IllegalStateException(String.format(
                "Unexpected anchor instruction: %s %s",
                mnemonic, target));
        }

        String evidence = String.format(
            "%s %s %s %s %s %s",
            args[1], currentProgram.getName(), memoryMin, memoryMax,
            mnemonic, target);
        Path marker = Path.of(args[0], currentProgram.getName() + ".mapping");
        Files.writeString(
            marker,
            evidence,
            StandardCharsets.UTF_8,
            StandardOpenOption.CREATE,
            StandardOpenOption.TRUNCATE_EXISTING);

        println(String.format(
            "SecureROM mapping verified for %s: %s-%s",
            currentProgram.getName(), memoryMin, memoryMax));
    }
}
