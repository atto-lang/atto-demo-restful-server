# Rust route generator migration

This independent host tool generates the existing legacy `.ores` route registry and configuration. It intentionally **does not** claim native `.atto` compiler support, actor execution, HTTP transport, AOT equivalence, or backend parity.

Run `bash scripts/generate-routes.sh --port 3000 --data-dir data` to publish `src/generated/routes.ores` and `config.ores` through atomic single-file replacements. `cargo test --offline --locked --manifest-path tools/route-gen/Cargo.toml` exercises discovery, path admission, symlink rejection, last-good preservation, JSON encoding, and deterministic ordering. The CI parity gate compares the output bytes with the existing Python oracle using the same concrete route and data directory inputs; the Python tests stay until equivalent Rust fixtures are independently reviewed.

Fail-closed limits: 10,000 directory entries and 4,096 routes; no symlink or special device in the route tree, no external route root or output-directory alias, no unsafe path segments, and a nonzero TCP port. No network access or Python interpreter is needed for the Rust generator. The non-atomic two-file output pair remains a documented limitation inherited from the legacy generator; a future grouped-publication transaction is separate work.
