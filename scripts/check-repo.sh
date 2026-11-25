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

# Each check reads its inventory from `git ls-files`. A listing that fails, a required inventory
# that is empty, or a listed file that cannot be read makes that check INCOMPLETE, never PASS.
inventory() {  # inventory VAR CHECK PATHSPEC...
  local var="$1" check="$2" out; shift 2
  if ! out="$(git ls-files -- "$@" 2>&1)"; then
    echo "INCOMPLETE  ${check}: cannot list tracked files: ${out}"; incomplete=1; return 1
  fi
  printf -v "$var" '%s' "$out"
}
readable() {  # readable FILE CHECK
  [ -f "$1" ] && [ -r "$1" ] && return 0
  echo "INCOMPLETE  $2: cannot read $1"; incomplete=1; return 1
}
report() {  # report CHECK OK DONE
  [ "$3" = 1 ] || return 0
  [ "$2" = 1 ] && echo "PASS  $1"
}

# shell ------------------------------------------------------------------------------
shell_ok=1; shell_done=0
if inventory files shell '*.sh' '.githooks/*'; then
  if [ -z "$files" ]; then
    echo "INCOMPLETE  shell: no tracked shell scripts found"; incomplete=1
  else
    shell_done=1
    while IFS= read -r f; do
      readable "$f" shell || { shell_done=0; continue; }
      if ! err="$(bash -n "$f" 2>&1)"; then fail shell "$f: $err"; shell_ok=0; fi
    done <<< "$files"
  fi
fi
report shell "$shell_ok" "$shell_done"

# records ----------------------------------------------------------------------------
records_ok=1; records_done=1
for module in docs/architecture/adr:adr docs/product/pdr:pdr docs/engineering/wdr:wdr; do
  dir="${module%%:*}"; key="${module##*:}"
  index="$dir/README.md"
  [ -f "$index" ] || { fail records "$index is missing"; records_ok=0; continue; }
  readable "$index" records || { records_done=0; continue; }
  inventory files records "$dir/[0-9]*.md" || { records_done=0; continue; }
  # a module with no records yet is valid (an empty listing that succeeded)
  [ -n "$files" ] || continue
  while IFS= read -r f; do
    readable "$f" records || { records_done=0; continue; }
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
  done <<< "$files"
done
report records "$records_ok" "$records_done"

# links ------------------------------------------------------------------------------
links_ok=1; links_done=0
if inventory files links '*.md'; then
  if [ -z "$files" ]; then
    echo "INCOMPLETE  links: no tracked Markdown files found"; incomplete=1
  else
    links_done=1
    while IFS= read -r f; do
      readable "$f" links || { links_done=0; continue; }
      d="$(dirname "$f")"
      targets="$(sed 's/`[^`]*`//g' "$f" | grep -o '\](\([^) ]*\))' | sed 's/^](\(.*\))$/\1/')" || true
      while IFS= read -r target; do
        path="${target%%#*}"
        case "$target" in ''|'#'*|http://*|https://*|mailto:*) continue ;; esac
        [ -n "$path" ] || continue
        [ -e "$d/$path" ] || { fail links "$f: '$target' does not exist"; links_ok=0; }
      done <<< "$targets"
    done <<< "$files"
  fi
fi
report links "$links_ok" "$links_done"

if [ "$failed" = 1 ]; then echo "RESULT: FAIL"; exit 1; fi
if [ "$incomplete" = 1 ]; then echo "RESULT: INCOMPLETE"; exit 2; fi
echo "RESULT: PASS"
