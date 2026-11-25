#!/usr/bin/env bash
# Offline regression for exact compiler pins and recursive dependency verification.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
export GIT_AUTHOR_NAME=Fixture GIT_AUTHOR_EMAIL=fixture@example.invalid
export GIT_COMMITTER_NAME=Fixture GIT_COMMITTER_EMAIL=fixture@example.invalid
init() {
  git init -q "$1"
  printf 'original\n' > "$1/payload.txt"
  git -C "$1" add payload.txt
  git -C "$1" commit -qm initial
}
expect_fail() {
  if "$@" > "$tmp/negative.log" 2>&1; then
    printf 'Unexpected success: %s\n' "$*" >&2
    exit 1
  fi
}
for name in compiler spin otel routing demo; do init "$tmp/$name"; done
mkdir -p "$tmp/demo/scripts"
cp "$root/scripts/check-deps.sh" "$tmp/demo/scripts/"
export ORESLANG_SOURCE_DIR="$tmp/compiler"
pin="$(git -C "$tmp/compiler" rev-parse HEAD)"
printf '%s\n' "$pin" > "$tmp/demo/SOURCE_REF"
check() { bash "$tmp/demo/scripts/check-deps.sh" "$@"; }
check --compiler
printf '%040d\n' 0 > "$tmp/demo/SOURCE_REF"
expect_fail check --compiler
printf '%s\nextra\n' "$pin" > "$tmp/demo/SOURCE_REF"
expect_fail check --compiler
printf '%s\n' "$pin" > "$tmp/demo/SOURCE_REF"
printf 'modified\n' > "$tmp/compiler/payload.txt"
expect_fail check --compiler
git -C "$tmp/compiler" checkout -- payload.txt
touch "$tmp/compiler/untracked"
expect_fail check --compiler
rm "$tmp/compiler/untracked"
expect_fail env ORESLANG_SOURCE_DIR="$tmp/absent" bash "$tmp/demo/scripts/check-deps.sh" --compiler
mkdir "$tmp/nonrepo"
expect_fail env ORESLANG_SOURCE_DIR="$tmp/nonrepo" bash "$tmp/demo/scripts/check-deps.sh" --compiler
mkdir "$tmp/fakebin"
printf '#!/bin/sh\nexit 42\n' > "$tmp/fakebin/git"
chmod +x "$tmp/fakebin/git"
expect_fail env PATH="$tmp/fakebin:$PATH" bash "$tmp/demo/scripts/check-deps.sh" --compiler
expect_fail check --all
git -c protocol.file.allow=always -C "$tmp/spin" submodule add -q "$tmp/routing" dependencies/http-routing
git -C "$tmp/spin" commit -qm 'pin routing'
git -c protocol.file.allow=always -C "$tmp/demo" submodule add -q "$tmp/spin" dependencies/spin
git -c protocol.file.allow=always -C "$tmp/demo" submodule add -q "$tmp/otel" dependencies/otel
git -C "$tmp/demo" add -A
git -C "$tmp/demo" commit -qm 'pin dependencies'
git -c protocol.file.allow=always -C "$tmp/demo" submodule update -q --init --recursive
check --all
router="$tmp/demo/dependencies/spin/dependencies/http-routing"
printf 'modified\n' > "$router/payload.txt"
expect_fail check --all
git -C "$router" checkout -- payload.txt
touch "$tmp/demo/dependencies/otel/untracked"
expect_fail check --all
rm "$tmp/demo/dependencies/otel/untracked"
printf '\n# unreviewed change\n' >> "$tmp/demo/.gitmodules"
expect_fail check --all
git -C "$tmp/demo" checkout -- .gitmodules
spin="$tmp/demo/dependencies/spin"
printf 'new revision\n' > "$spin/payload.txt"
git -C "$spin" add payload.txt
git -C "$spin" commit -qm 'unexpected revision'
expect_fail check --all
git -C "$tmp/demo" submodule update -q --recursive
check --all
printf 'DEPENDENCY_CHECKER_PASS: clean positives and 12 negative controls; no guest executed\n'
