# Canonical project-root migration gate

The competing October candidates (#11 and #12) have been consolidated. Their source and stronger archive preflight remain in the merge ancestry at `f480fe3f365cffd3f7b759548c4c6db58471c909`. Do not switch the working REST runtime to those historical compiler pins, root-level library relocation, or new Python packaging scripts.

The newer #2 runtime receipt records that the pinned legacy compiler links the relative form but fails the canonical import. This is a real compatibility blocker, not merely a formatting preference. Preserve the current relative imports and src/lib layout until a compatible compiler is demonstrated. The [project] manifest is already included by #2.

Run `bash scripts/verify-project-root-imports.sh` on a clean, prepared checkout of the exact compiler/dependency graph. The script executes the same two-module project twice, first with a relative import and then with a canonical +/ import. Both runs must exit zero and print exactly 42. It neither mutates the application source nor treats a compiler failure as success. A passing scalar probe is necessary but not sufficient: full canonical route generation, packaging, linked HTTP execution, and native distribution validation are still required before enabling the migration.

`bash scripts/test-project-root-probe.sh` tests one positive and four negative harness cases without a real compiler. These host checks passed locally; Git blob identities were matched. No guest execution is claimed. The previous packaging candidates' symlink, deterministic ZIP, path bounds, and import closure tests are retained in history and must be ported to policy-compatible host tooling before enabling canonical packaging.
