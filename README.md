> **AI agent instructions (organization-wide):** Before working on code, issues, or pull requests, read and follow the [organization `AGENTS.md`](https://github.com/atto-lang/.github/blob/main/AGENTS.md), including its **merge-first stealth-development policy**. Honor any repository-local `AGENTS.md`, explicit holds, and GitHub-enforced rules.

# atto-demo-restful-server

Reference REST API server demonstrating HTTP actors and routing in AttoLang.

## Naming migration and language authority

This repository is maintained at [atto-lang/atto-demo-restful-server](https://github.com/atto-lang/atto-demo-restful-server); use `https://github.com/atto-lang/atto-demo-restful-server.git` for Git remotes and canonical `.atto` source examples. The normative language contract is [atto-spec](https://github.com/atto-lang/atto-spec), with executable guest evidence tracked by [atto-platform-conformance](https://github.com/atto-lang/atto-platform-conformance). Follow current ownership, borrowing, effects, actor, and syntax rules there; do not infer implemented features from a README or unexecuted CI.

## What this project explores

Example HTTP routes, actor-based request processing, and API behavior.

## How to use these examples

1. Check the repository contents for `.atto` examples and target-specific project manifests.
2. Use the compiler/backend indicated by each example's actual files and scripts.
3. Run checked-in tests or example commands only where documented and verified.
4. Record compiler revision, expected output, and actual result when reporting an issue.

## Portability and status

These examples are intended to demonstrate AttoLang concepts. Examples may depend on unfinished language features or particular backends; their presence is not evidence that every listed feature executes on all targets. Unsupported features should be marked in the individual example's documentation.

## Links

- [AttoLang repositories](https://github.com/atto-lang)
- [Canonical language specification](https://github.com/atto-lang/atto-spec)
- [Backend conformance](https://github.com/atto-lang/atto-platform-conformance)

## Repository ownership and contribution routing

**Belongs here:** Runnable reference REST server and actor-backed HTTP request/response examples, routes, fixtures and deployment notes.

**Belongs elsewhere:** Reusable routing semantics in atto-http-routing, generic API app scaffold in atto-api-server.atto and performance data in atto-restful-server-perf-benchmarks.

**Security and portability boundary:** Bind host and ports explicitly, validate requests and cancellation, bound response sizes, and document security settings before internet exposure.

AttoLang is the canonical project name; new source, examples and documentation use `.atto` and the `atto-lang` repository organization. This README defines scope, not feature readiness.

**Acceptance:** name exact source SHA/tree, runtime/toolchain, positive and negative checks and execution receipt before claiming support. Host-only tests and empty CI steps do not prove guest execution.

## Migration and release evidence

The legacy Oreslang REST demonstration has moved into the AttoLang repository namespace. This is a successor repository, not proof of a same-ID GitHub transfer. Preserve the working legacy `.ores` sources and exact compiler/dependency pins until their replacements have executed successfully. The language and reference examples belong in `atto-lang`; production multi-tenant cloud infrastructure, registry, identity and billing belong in `atto-co`.

For a release, record the demo commit/tree, compiler and nested dependency revisions, toolchain, executed test steps and positive/negative results. Source-only route checks do not establish native HTTP actor execution, and a zero-step Actions job is not executed evidence. Validate real HTTP behavior and the applicable native distribution modes before claiming runtime support. Never publish private dependency source in a public repository.

## Rust route generation and native release checks

The legacy pinned REST app uses the Rust route publisher through `bash scripts/generate-routes.sh` (Cargo required). The retained Python generator is a host-only parity oracle, not a production route-generation dependency. See [route generator contracts](docs/RUST_ROUTE_GENERATOR.md) for filesystem trust boundaries, exact-byte parity, and remaining limitations.

Run the dependency-free publisher tests with `cargo test --offline --locked --manifest-path tools/route-gen/Cargo.toml`. With the authorized exact compiler and GraalVM Native Image SDK, run `bash scripts/verify-native-release.sh aot` or `bash scripts/verify-native-release.sh hybrid`. These commands require a real server executable and exercise HTTP, telemetry, shutdown and persistence. A native host running interpreted guest handlers is not proof of full guest AOT or other backend parity.
