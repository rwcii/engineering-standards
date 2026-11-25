#!/usr/bin/env bash
# check-repo.sh — the deterministic checks of this repository (`repo-checks` in CI).
#
# Usage: scripts/check-repo.sh [BASE]
#   BASE is the commit the change is compared against (default: origin/develop).
#
# Checks:
#   whitespace  `git diff --check` over BASE...HEAD
#   shell       `bash -n` on every tracked shell script and hook
#   records     each ADR/PDR/WDR record: frontmatter keys, its number matches the file name,
#               and its row in the module index has the record's status
#   links       every relative Markdown link in a tracked .md file names an existing path
#               (anchors are not checked)
#
# Exit status: 0 all checks pass; 1 a check failed; 2 INCOMPLETE — a required check could
# not run (WDR 004, Decision 8), which is never a pass.
set -uo pipefail

base="${1:-origin/develop}"
root="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "INCOMPLETE: not a Git checkout"; exit 2; }
cd "$root" || exit 2

failed=0
incomplete=0
fail() { echo "FAIL  $1: $2"; failed=1; }

# whitespace -------------------------------------------------------------------------
if ! git rev-parse --verify --quiet "${base}^{commit}" >/dev/null; then
  echo "INCOMPLETE  whitespace: base '${base}' is not a commit in this checkout"
  incomplete=1
elif ! out="$(git diff --check "${base}...HEAD" 2>&1)"; then
  fail whitespace "$(printf '%s' "$out" | head -n 20)"
else
  echo "PASS  whitespace"
fi

# shell ------------------------------------------------------------------------------
shell_ok=1
while IFS= read -r f; do
  [ -f "$f" ] || continue
  if ! err="$(bash -n "$f" 2>&1)"; then fail shell "$f: $err"; shell_ok=0; fi
done < <(git ls-files -- '*.sh' '.githooks/*')
[ "$shell_ok" = 1 ] && echo "PASS  shell"

# records ----------------------------------------------------------------------------
records_ok=1
for module in docs/architecture/adr:adr docs/product/pdr:pdr docs/engineering/wdr:wdr; do
  dir="${module%%:*}"; key="${module##*:}"
  index="$dir/README.md"
  [ -f "$index" ] || { fail records "$index is missing"; records_ok=0; continue; }
  while IFS= read -r f; do
    name="$(basename "$f")"
    num="${name%%-*}"
    case "$num" in 000) continue ;; esac
    if [ "$(head -n 1 "$f")" != "---" ]; then fail records "$f: no YAML frontmatter"; records_ok=0; continue; fi
    front="$(awk 'NR==1{next} /^---$/{exit} {print}' "$f")"
    for k in "$key" title status created updated tags; do
      printf '%s\n' "$front" | grep -q "^${k}:" || { fail records "$f: frontmatter has no '${k}'"; records_ok=0; }
    done
    id="$(printf '%s\n' "$front" | sed -n "s/^${key}: *\"\{0,1\}\([0-9.]*\)\"\{0,1\} *$/\1/p")"
    [ "$id" = "$num" ] || { fail records "$f: ${key} is '${id}', file name says '${num}'"; records_ok=0; }
    status="$(printf '%s\n' "$front" | sed -n 's/^status: *"\{0,1\}\([a-z_]*\)"\{0,1\} *$/\1/p')"
    row="$(grep -F "](${name})" "$index" | head -n 1)"
    if [ -z "$row" ]; then
      fail records "$f: no row in $index"; records_ok=0
    else
      # the status cell is the last column; a parenthetical note after it is ignored
      listed="$(printf '%s\n' "$row" | awk -F'|' '{print $(NF-1)}' | sed 's/(.*//' | tr -d ' ' | tr 'A-Z' 'a-z')"
      want="$(printf '%s' "$status" | tr -d '_')"
      [ "$(printf '%s' "$listed" | tr -d '_')" = "$want" ] \
        || { fail records "$f: status '${status}', $index lists '${listed}'"; records_ok=0; }
    fi
  done < <(git ls-files -- "$dir/[0-9]*.md")
done
[ "$records_ok" = 1 ] && echo "PASS  records"

# links ------------------------------------------------------------------------------
links_ok=1
while IFS= read -r f; do
  d="$(dirname "$f")"
  while IFS= read -r target; do
    path="${target%%#*}"
    case "$target" in ''|'#'*|http://*|https://*|mailto:*) continue ;; esac
    [ -n "$path" ] || continue
    [ -e "$d/$path" ] || { fail links "$f: '$target' does not exist"; links_ok=0; }
  done < <(sed 's/`[^`]*`//g' "$f" | grep -o '\](\([^) ]*\))' | sed 's/^](\(.*\))$/\1/')
done < <(git ls-files -- '*.md')
[ "$links_ok" = 1 ] && echo "PASS  links"

if [ "$failed" = 1 ]; then echo "RESULT: FAIL"; exit 1; fi
if [ "$incomplete" = 1 ]; then echo "RESULT: INCOMPLETE"; exit 2; fi
echo "RESULT: PASS"
