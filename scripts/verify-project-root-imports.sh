#!/usr/bin/env bash
# Opt-in real compiler gate; never changes the working REST source layout.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
expected="$(cat "$root/SOURCE_REF")"
[[ "$expected" =~ ^[0-9a-f]{40}$ ]] || { echo 'Invalid SOURCE_REF' >&2; exit 65; }
export ORESLANG_SOURCE_DIR="${ORESLANG_SOURCE_DIR:-$root/.cache/compiler-$expected}"
bash "$root/scripts/check-deps.sh" --all
compiler="$root/dependencies/spin/scripts/compiler.sh"
[[ -f "$compiler" && -f "$root/.ores.pkg.toml" ]] || exit 65
project="$(mktemp -d)"
trap 'rm -rf -- "$project"' EXIT
mkdir -p "$project/src" "$project/lib"
cp "$root/.ores.pkg.toml" "$project/.ores.pkg.toml"
cat > "$project/lib/helper.ores" <<'GUEST'
define module helper as
  pub fnc answer(): int { return 42; }
end
GUEST
probe() {
  local kind="$1" import_path="$2" status=0
  printf 'import module helper from "%s";\npub async routine main(): void { stdio.println(helper.answer()); return; }\n' "$import_path" > "$project/src/main.ores"
  (cd "$project" && bash "$compiler" "$project/src/main.ores") > "$project/out" 2> "$project/err" || status=$?
  if [[ "$status" != 0 || "$(cat "$project/out")" != 42 ]]; then
    cat "$project/err" >&2
    printf 'PROJECT_ROOT_%s=FAIL status=%s compiler=%s\n' "$kind" "$status" "$expected" >&2
    return 1
  fi
  printf 'PROJECT_ROOT_%s=PASS compiler=%s output=42\n' "$kind" "$expected"
}
probe RELATIVE ../lib/helper
probe CANONICAL +/lib/helper
printf 'Canonical scalar import verified; full REST migration and native delivery still require separate acceptance.\n'
