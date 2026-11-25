#!/usr/bin/env bash
# Host-only checks of the gate, using a fake compiler; never a guest receipt.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/scripts" "$tmp/dependencies/spin/scripts"
cp "$root/scripts/verify-project-root-imports.sh" "$tmp/scripts/"
printf '%040d\n' 1 > "$tmp/SOURCE_REF"
printf 'schema_version = "1"\n' > "$tmp/.ores.pkg.toml"
cat > "$tmp/scripts/check-deps.sh" <<'GUARD'
[[ "$1" == --all && "${PROBE_FAKE_MODE:-ok}" != guard_fail ]]
GUARD
cat > "$tmp/dependencies/spin/scripts/compiler.sh" <<'COMPILER'
set -euo pipefail
[[ -f .ores.pkg.toml && -f lib/helper.ores && "$1" == "$PWD/src/main.ores" ]]
mode="${PROBE_FAKE_MODE:-ok}"
if grep -Fq 'from "+/lib/helper";' "$1"; then
  [[ "$mode" != canonical_fail ]] || exit 19
  [[ "$mode" != wrong_output ]] || { echo 41; exit 0; }
else
  grep -Fq 'from "../lib/helper";' "$1"
  [[ "$mode" != relative_fail ]] || exit 18
fi
echo 42
COMPILER
run() { PROBE_FAKE_MODE="$1" bash "$tmp/scripts/verify-project-root-imports.sh" > "$tmp/out" 2> "$tmp/err"; }
run ok
grep -Fq 'PROJECT_ROOT_RELATIVE=PASS' "$tmp/out"
grep -Fq 'PROJECT_ROOT_CANONICAL=PASS' "$tmp/out"
for mode in canonical_fail wrong_output relative_fail guard_fail; do
  if run "$mode"; then echo "Unexpected success: $mode" >&2; exit 1; fi
  ! grep -Fq 'PROJECT_ROOT_CANONICAL=PASS' "$tmp/out"
  case "$mode" in
    canonical_fail|wrong_output) grep -Fq 'PROJECT_ROOT_RELATIVE=PASS' "$tmp/out";;
    relative_fail|guard_fail) ! grep -Fq 'PROJECT_ROOT_RELATIVE=PASS' "$tmp/out";;
  esac
done
printf 'PROJECT_ROOT_PROBE_HOST_PASS: 1 positive, 4 negatives; guest NOT_EXECUTED\n'
