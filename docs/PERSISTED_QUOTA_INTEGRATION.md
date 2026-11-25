# Persisted resource quota integration

The original quota branch (#13), oversized GET follow-up (#14), and descriptor-bounded read follow-up (#15) are consolidated into the current-main integration candidate #16. The older intermediate compiler pins and source-only workflows are superseded, not production alternatives.

The integration retains the 1 MiB UTF-8 persisted ceiling, 64 KiB ingress boundary, atomic replacement, bounded GET/PATCH, quota staging cleanup, and tests for Unicode boundaries, at-limit reads, oversized persisted data, and symlink rejection. Both route generators and the native configuration renderer must emit the staging path. The integrated branch retains the Rust publisher, archive guard, and read-only smoke harness from main.

Historical host-only evidence: legacy run 41887319336 tested the bounded-read stack; alternate runner 42953910124 tested the later integrated legacy tree. Neither proves real guest HTTP behavior on the current compiler pin. Before merging #16 to main, execute the current route/host tests plus compiler-backed HTTP quota and failure-cleanup tests and validate the native delivery path. Do not use this consolidation merge as release evidence.
