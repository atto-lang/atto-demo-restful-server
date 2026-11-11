# REST runtime migration checkpoint — 2026-11-10

## Repository and dependency provenance

Source main: `9dac3a0c054ced46829859e37cb8eb443623845b`.
Destination documentation tip: `7ee16203f263b7062c49f109d67ff5c04d3e2801`.
The migration merge preserves both histories. No repository transfer, deletion,
force push, release publication or main-branch merge is part of this work.
Destination was inspected and confirmed private before importing source history.
Its original README is retained as `DESTINATION_SCOPE.md`.

Java compiler: `10792c332e6a31d685ca65960f841543fe95fbb8` (Spin's own compatibility pin).
Spin: `fad37bfbc6cdd4267a84ed090b22c7ed112f03a4`.
Routing, transitively pinned by Spin: `1d6ee5bce2dbd795a24e15f69e26a77adfc49808`.
OTel: `ee6aa6f54c7ba60efa2f199426526911592d0a65`.
Spin also pins an unused OTel submodule at `5fe62a3447e77072cfd30850a96ef654a18008f7`;
the application imports the top-level OTel gitlink. Runtime guest imports remain
relative and `.ores` is retained for compatibility with this compiler.

Reconciles source drafts #10 (revision-addressed compiler cache, exact dependency
checks), #14 (evaluated canonical imports, deferred on the concrete linker
failure below), and #71 (read-only transport probe retained unchanged). These
PRs are not merged or rewritten by this migration.

## Supported execution and dependencies

Application behavior remains in `src/**/*.ores`, Spin and routing guest source.
Java application files only bootstrap the native image and unpack embedded source.
Host Python is existing route-generation/acceptance tooling; it does not model
HTTP or persistence semantics. No new Python source files are introduced.

Development requires JDK 25, Maven, Git, Python 3.9+, curl and authenticated access
to the pinned legacy dependency repositories. Native builds require the matching
Truffle SDK: GraalVM CE `25.3.4.1+1.1` (Java `25.0.4.1`) on macOS ARM64.
Oracle Native Image `25.0.4` fails with the pinned Truffle `25.3.4.1`:
`ClassNotFoundException: com.oracle.truffle.api.impl.TruffleLocator`.
The builder now rejects a mismatched SDK before starting compilation.

The extracted deployment needs the matching OS/architecture system libraries
and bundled `liboresthread.dylib`. It requires no JVM, Python, Maven, Git, compiler
checkout or telemetry collector. AOT means a native runtime interpreting guest
handlers, not ahead-of-time lowering of application code. Hybrid includes guest
JIT; each build mode needs its own archive validation. No other platform/backend
is certified by the macOS results.

## Acceptance contract

`./scripts/test.sh` invokes the genuine compiler and guest server. Expected:
CRUD/error paths, HEAD/OPTIONS, restart persistence, telemetry correlation,
38 HTTP/route checks and core perf/debug output after SIGTERM. Raw socket probes
hold an admitted partial PUT in a guest handler: three simultaneous excess
connections return 503 without a guest trace; the held read expires around ten
seconds with 500 on this pin; subsequent health succeeds. Disconnect recovery
must also return health to 200 and leave persisted bytes unchanged. SIGTERM during
a held request must exit within eight seconds and close the listener without
committing its incomplete upload. It does not certify graceful draining.

`python3 tests/native_distribution.py ARCHIVE` unpacks to a fresh directory,
checks all packaged hashes, mode enforcement and missing-carrier failure, and
runs the same HTTP suite with `PATH=/nonexistent` and developer variables removed.
Its server working directory is outside the source/build tree. The driver alone
uses Python/curl. Hybrid additionally executes the suite in forced AOT mode.
`manifest.json` records application/compiler commits and trees, compiler JAR hash,
recursive dependency pins, Native Image version and packaged file hashes.

## Concrete compiler blockers

1. Java main `6d8eb70048eafc9a84c5aebe9c1bb06104f16e76` rejects current dependency
   syntax: `routes.register(rt borrow mut builder);` reports
   `legacy 'rt borrow mut value' is not accepted; use 'rt mut borrow value'`.
   Spin and routing also contain that syntax. Updating the entire dependency
   graph is separate from this bounded REST artifact task; no compiler rewrite
   or unrelated Spin checkout changes were made.
2. With the compatible compiler, changing app imports to `+/src/lib/telemetry`
   causes `import target ... is not linked yet; all members of an import cycle
   must be linked before init` after listener startup. Even canonicalizing all
   application imports hits the same error for `+/dependencies/spin/src/spin`.
   Relative imports execute the full acceptance suite. This is why #14 remains
   unlanded rather than treating source-layout tests as runtime evidence.

Single transport admission is not `serial http actor` lowering, nor independent
`requestConcurrency`/`messageConcurrency`. Those features remain unverified and
unimplemented by this demo. Process exit and diagnostic flushing are not graceful
HTTP drain evidence. Source-origin merge checks remain untouched. Local execution
was available; no Actions budget fallback or cross-organization token was used.

Exact tested artifact revisions, commands, exit statuses, output and hashes are
recorded in the accompanying execution receipt and retained local logs. Hosted
structural CI, when present, is not guest or native execution evidence.
