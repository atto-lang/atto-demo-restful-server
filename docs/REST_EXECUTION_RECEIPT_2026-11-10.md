# REST execution receipt — 2026-11-10

Application/acceptance commit `f8346b9e3292b3c146b88b2360e28d35e02d82a3`, tree `4292fcebcc55c68d0be2576f62164078c56c0982`.
Compiler commit `3a4f0c737669fbb691ac84ec1f80e9589839c6fe`, tree `d70f29809975af41a99aaf9d761c3eadc6416f90`.
Legacy source commit `9dac3a0c054ced46829859e37cb8eb443623845b`, tree `d1b1d09aee259c420fb8b3f7a739675e0e5fefc8`.
Both native archives were built from clean checkouts at those exact application/compiler revisions. The later receipt/integration-identity commit does not change packaged guest, Java or build inputs.

Mach-O minimum deployment target is **macOS 26.0** for both executable and carrier (SDK 26.5). Runtime libraries are bundled liboresthread plus macOS CoreServices, Foundation, CFNetwork, CoreFoundation, libSystem, libz and libobjc; no fully static or older-macOS claim.

Toolchain: macOS ARM64, GraalVM CE `25.3.4.1+1.1`, Java `25.0.4.1`, Truffle SDK `25.3.4.1`. Set `JAVA_HOME` to that GraalVM, `ORES_JAVA=$JAVA_HOME/bin/java`, and `ORESLANG_SOURCE_DIR` to the clean pinned compiler.

| Command | Exit | Actual outcome |
| --- | --- | --- |
| `./scripts/test.sh` | 0 | 44 checks; six malformed header rejections; 10 diagnostic HTTP requests; 234 core phases; 2 debug events; 10 OTel spans |
| `python3 -m unittest discover -s tests -p test_route_publication.py -v` | 0 | 62 tests OK |
| `./scripts/build-native.sh aot` | 0 | built matching native distribution |
| `python3 tests/native_distribution.py dist/rest-server-aot-darwin-arm64.tar.gz` | 0 | PASS: 6 malformed header requests rejected before guest admission; PASS: held upload deadline status=500 elapsed=10.008s; excess requests=503; PASS: SIGTERM during upload exited=143 elapsed=0.018s; graceful draining NOT_VERIFIED; PASS: 44 integration and route-generation checks; relocation/modes/checksums/missing-carrier passed |
| `./scripts/build-native.sh hybrid` | 0 | built matching native distribution |
| `python3 tests/native_distribution.py dist/rest-server-hybrid-darwin-arm64.tar.gz` | 0 | PASS: 6 malformed header requests rejected before guest admission; PASS: held upload deadline status=500 elapsed=10.005s; excess requests=503; PASS: SIGTERM during upload exited=143 elapsed=0.009s; graceful draining NOT_VERIFIED; PASS: 44 integration and route-generation checks; PASS: 6 malformed header requests rejected before guest admission; PASS: held upload deadline status=500 elapsed=10.005s; excess requests=503; PASS: SIGTERM during upload exited=143 elapsed=0.008s; graceful draining NOT_VERIFIED; PASS: 44 integration and route-generation checks; relocation/modes/checksums/missing-carrier passed |
| `BASE_URL=http://127.0.0.1:<ephemeral> bash scripts/read-only-http-transport-smoke.sh` | 0 | six read-only requests; lower-level actor/concurrency/shutdown parity explicitly NOT_VERIFIED |
| `bash scripts/test-guards.sh` | 0 | source/submodule guard tests passed |
| `javac --release 21 -d .cache/archive-test native/src/dev/oreslang/demo/EmbeddedAppArchive.java native/test/dev/oreslang/demo/EmbeddedAppArchiveTest.java && java -cp .cache/archive-test dev.oreslang.demo.EmbeddedAppArchiveTest` | 0 | embedded archive tests passed |
| `PATH=/opt/homebrew/bin:$PATH bash ci/test-source-policy.sh` | 0 | SOURCE_POLICY_NEGATIVE_TESTS_PASS scenarios=8 |
| `PATH=/opt/homebrew/bin:$PATH SOURCE_POLICY_MODE=rest-legacy bash ci/source-policy.sh` | 0 | structural pass; existing Python migration remains exposed; not guest proof |
| `ORESLANG_SOURCE_DIR=$PWD/.cache/compiler bash dependencies/spin/scripts/compiler.sh $PWD/.cache/canonical-repro/src/main.ores` | 1 | import target not linked yet |
| `same minimal source with ../lib/helper import` | 0 | 42 |
| `mvn -q -Dtest=NativeHttpTest test (compiler checkout)` | 0 | 18 tests; zero failures/errors/skips |
| `ORESLANG_COMPILER=$PWD/dependencies/spin/scripts/compiler.sh python3 dependencies/spin/tests/integration.py` | 0 | 110 checks PASS |
| `compiler.sh --check --platform=server router_semantics.ores; compiler.sh --platform=server router_semantics.ores; diff -u expected.txt actual` | 0 | exact golden match |

The Spin integration module was called directly: its wrapper still pins original compiler `10792c3`. No Spin source was modified. Routing was independently checked/executed against the revised compiler and compared with the checked-in golden output.

## Native archive hashes

- `rest-server-aot-darwin-arm64.tar.gz`: `4c3fee666c68a8cffb15828e0dd74a0e5f2cb0ad10308ba4ff8ac3b14db7b594` (23560959 bytes).
  Binary SHA-256: `05ad4357f0514f7b58321a556f3fdd7054bbb329ce18967d4a05917cc35c4d8a`.
- `rest-server-hybrid-darwin-arm64.tar.gz`: `467930e5d2cd18a30a8b7878c45b05f73e01d6f6bf9a60cbc26d6e5b718578f8` (32075350 bytes).
  Binary SHA-256: `a33b0064682dd9027e67aa65a2b502843b87d8fbe3f4c97eaea4786ea60a1857`.

`manifest.json` inside each archive records the application/compiler commits and trees, compiler JAR hash, recursive dependency gitlinks, toolchain and packaged file hashes. `tests/native_distribution.py` starts the relocated binary from a fresh working directory with `PATH=/nonexistent` and Java/compiler developer variables removed. The Python/curl driver runs outside that server environment.

## Hosted structural evidence

At application head `f8346b9e3292b3c146b88b2360e28d35e02d82a3`, these four runs passed with real executed steps, confirmed through the GitHub connector:

- [Route publication](https://github.com/atto-lang/atto-demo-restful-server/actions/runs/42938545479)
- [Source hygiene](https://github.com/atto-lang/atto-demo-restful-server/actions/runs/42938545478)
- [Input gate](https://github.com/atto-lang/atto-demo-restful-server/actions/runs/42938545463)
- [Submodule trust](https://github.com/atto-lang/atto-demo-restful-server/actions/runs/42938545452)

These are host/structural jobs, separate from the locally executed guest/native checks. No Actions budget fallback or cross-organization token was needed. Both main branches and required origin checks remain untouched.

## Failures resolved or retained

- The original compiler pin served duplicate Host with 200. The bounded 12-line transport backport in [compiler draft PR #2806](https://github.com/ores-truffle-oreslang/oreslang-source.java/pull/2806) now passes the guest-backed regression and all 110 Spin checks. The compiler dependency remains an explicit draft compatibility branch.
- Oracle Native Image `25.0.4` failed with `TruffleLocator` missing; the matching CE toolchain builds both archives. The builder now rejects an SDK mismatch early.
- Canonical `+/` import linking still fails on the compatible compiler (minimal two-module reproduction and positive relative-import control retained). Relative `.ores` imports execute. Current Java main also rejects the dependency graph’s old mutable-borrow syntax.

## Retained local evidence

`/Users/alexandermills/codes/atto-rest-01a1c81d/evidence/` contains the machine-readable `execution-receipt.json`, raw build/acceptance logs, per-process server JSONL, minimal import repro/control, the 18-test JUnit XML and hosted job/step snapshots. Artifacts remain in the isolated checkout’s `dist/`. Earlier pre-backport results are labeled separately.

The supported result is the single-admission REST store on macOS ARM64. A busy read expires at ten seconds with 500. SIGTERM exits and preserves incomplete-upload data; graceful draining, serial HTTP actor lowering, independent requestConcurrency/messageConcurrency and other platforms/backends remain unverified.
