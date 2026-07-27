# Provenance

The original bundle did not provide an independently verifiable acquisition
chain for these two images. Their filenames were retained unchanged and their
current bytes are pinned by SHA-256.

| Input | SHA-256 |
| --- | --- |
| `images/brom20024` | `84a94cde9ecd8aae22390225f31c2d394eca05a7be836f010ee5b429992029b6` |
| `images/brom2014` | `f10798e0ea66722aa272cf697678154ea18d79cfa03f1db567dc2564d2ffa55f` |

Unknowns:

- Original extraction method and device identity.
- External hash attestation.
- Chain of custody before this workspace.
- Redistribution status of the Apple SecureROM images.

Do not silently replace either file. Add a new input with its own hash and
acquisition note.

