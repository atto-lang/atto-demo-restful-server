# atto-demo-restful-server

Reference REST API server demonstrating HTTP actors and routing in AttoLang.

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

AttoLang is the public name; preserve existing Oreslang/.ores compatibility and use canonical .atto for new portable library source. This README defines scope, not feature readiness.

**Acceptance:** name exact source SHA/tree, runtime/toolchain, positive and negative checks and execution receipt before claiming support. Host-only tests and empty CI steps do not prove guest execution.
