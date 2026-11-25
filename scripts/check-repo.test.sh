#!/usr/bin/env bash
# check-repo.test.sh — shows that each check in check-repo.sh can fail (WDR 004, Decision 5).
#
# Each case copies the tracked files of the checkout into a scratch repository, seeds one defect in a new
# commit, runs check-repo.sh against the clean commit and asserts its exit status.
# Usage: scripts/check-repo.test.sh      (no network, writes only under a temporary folder)
set -euo pipefail

src="$(git rev-parse --show-toplevel)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
pass=0; fails=0

setup() {
  rm -rf "$tmp/repo"; mkdir -p "$tmp/repo"
  (cd "$src" && git ls-files -z | tar --null -T - -cf -) | tar -x -C "$tmp/repo"
  git -C "$tmp/repo" init -q
  git -C "$tmp/repo" -c user.name=t -c user.email=t@example.invalid add -A
  git -C "$tmp/repo" -c user.name=t -c user.email=t@example.invalid -c commit.gpgsign=false commit -qm base
  git -C "$tmp/repo" -c tag.gpgsign=false tag base
}

seed() {
  git -C "$tmp/repo" -c user.name=t -c user.email=t@example.invalid add -A
  git -C "$tmp/repo" -c user.name=t -c user.email=t@example.invalid -c commit.gpgsign=false commit -qm defect
}

# expect NAME EXIT LINE [BASE]: check-repo.sh exits EXIT and prints LINE (a fixed string)
expect() {
  local name="$1" want="$2" line="$3" ref="${4:-base}" got=0
  (cd "$tmp/repo" && PATH="${SHIM:-}${SHIM:+:}$PATH" bash "$src/scripts/check-repo.sh" "$ref" >"$tmp/out" 2>&1) || got=$?
  if [ "$got" = "$want" ] && grep -qF -- "$line" "$tmp/out"; then
    echo "ok    $name (exit $got)"; pass=$((pass + 1))
  else
    echo "FAIL  $name: want exit $want and '$line', got exit $got"; sed 's/^/      /' "$tmp/out"; fails=$((fails + 1))
  fi
}

wdr=docs/engineering/wdr/004-verification-and-testing-discipline.md

setup; expect "clean tree passes" 0 "RESULT: PASS"

setup; printf 'trailing space \n' >> "$tmp/repo/$wdr"; seed
expect "whitespace error fails" 1 "FAIL  whitespace"

setup; printf 'if then\n' > "$tmp/repo/scripts/broken.sh"; seed
expect "shell syntax error fails" 1 "FAIL  shell: scripts/broken.sh"

setup; sed -i 's/^wdr: "004"/wdr: "014"/' "$tmp/repo/$wdr"; seed
expect "record number mismatch fails" 1 "wdr is '014', file name says '004'"

setup; sed -i '/^title:/d' "$tmp/repo/$wdr"; seed
expect "missing frontmatter key fails" 1 "frontmatter has no 'title'"

setup; sed -i 's/^status: .*/status: superseded/' "$tmp/repo/$wdr"; seed
expect "index status mismatch fails" 1 "status 'superseded'"

setup; sed -i '/(004-verification-and-testing-discipline.md)/d' "$tmp/repo/docs/engineering/wdr/README.md"; seed
expect "record missing from index fails" 1 "no row in docs/engineering/wdr/README.md"

setup; printf '\nSee [gone](no-such-file.md).\n' >> "$tmp/repo/README.md"; seed
expect "broken relative link fails" 1 "'no-such-file.md' does not exist"

setup; expect "unknown base is INCOMPLETE, not PASS" 2 "RESULT: INCOMPLETE" no-such-ref

# a git that cannot list tracked files: every inventory check is INCOMPLETE, never PASS
real_git="$(command -v git)"
mkdir -p "$tmp/shim"
printf '#!/bin/sh\n[ "$1" = ls-files ] && { echo "fatal: simulated failure" >&2; exit 128; }\nexec "%s" "$@"\n' "$real_git" > "$tmp/shim/git"
chmod +x "$tmp/shim/git"
setup; SHIM="$tmp/shim" expect "failed file listing is INCOMPLETE" 2 "INCOMPLETE  shell: cannot list tracked files"
if grep -q '^PASS  \(shell\|records\|links\)' "$tmp/out"; then
  echo "FAIL  failed file listing still printed a PASS"; fails=$((fails + 1))
else
  echo "ok    failed file listing prints no PASS for shell, records or links"; pass=$((pass + 1))
fi

# a tracked file that cannot be read is INCOMPLETE (skipped when running as root)
if [ "$(id -u)" != 0 ]; then
  setup; chmod 000 "$tmp/repo/CONTRIBUTING.md"
  expect "unreadable tracked file is INCOMPLETE" 2 "INCOMPLETE  links: cannot read CONTRIBUTING.md"
  chmod 644 "$tmp/repo/CONTRIBUTING.md"
fi

# promotion-source: only this repository's develop may open a pull request into main
promo() {
  local name="$1" want="$2" got=0; shift 2
  bash "$src/scripts/check-promotion-source.sh" "$@" >"$tmp/out" 2>&1 || got=$?
  if [ "$got" = "$want" ]; then echo "ok    $name (exit $got)"; pass=$((pass + 1))
  else echo "FAIL  $name: want exit $want, got $got"; sed 's/^/      /' "$tmp/out"; fails=$((fails + 1)); fi
}
promo "release from develop passes" 0 main develop o/r o/r
promo "feature into develop passes" 0 develop feature/x o/r o/r
promo "feature branch into main fails" 1 main feature/x o/r o/r
promo "fork's develop into main fails" 1 main develop fork/r o/r

echo "passed $pass, failed $fails"
[ "$fails" = 0 ]
