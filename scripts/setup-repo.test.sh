#!/usr/bin/env bash
# setup-repo.test.sh — shows that setup-repo.sh detects each policy difference and applies the
# policy in a safe order (WDR 004, Decision 5). Uses a fake `gh` that serves fixture JSON from a
# temporary folder; it calls no network and changes no real repository.
# Usage: scripts/setup-repo.test.sh
set -uo pipefail

src="$(git rev-parse --show-toplevel)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
pass=0; fails=0
command -v jq >/dev/null || { echo "INCOMPLETE: jq is required"; exit 2; }

mkdir -p "$tmp/bin"
cat > "$tmp/bin/gh" <<'GH'
#!/usr/bin/env bash
# fake gh: GET serves $FAKE/<path with / as _>.json; PATCH, PUT and POST update the fixtures.
echo "$*" >> "$FAKE/log"
case "$1" in auth) exit 0 ;; repo) echo o/r; exit 0 ;; esac
shift
method=GET; path=""; jqexpr=""; fields=(); input=""
while [ $# -gt 0 ]; do
  case "$1" in
    --method) method="$2"; shift 2 ;;
    --jq) jqexpr="$2"; shift 2 ;;
    --input) input="$(cat)"; shift 2 ;;
    -F|-f) fields+=("$2"); shift 2 ;;
    *) path="$1"; shift ;;
  esac
done
if [ -f "$FAKE/fail-$method" ]; then cat "$FAKE/fail-$method" >&2; exit 1; fi
if [ "$method" = GET ] && [ -f "$FAKE/fail-GET-after-auto" ] && [ "$(jq -r .allow_auto_merge "$FAKE/repos_o_r.json")" = true ] \
   && grep -q 'allow_auto_merge=true' "$FAKE/fields" 2>/dev/null; then
  echo "HTTP 502: simulated read failure" >&2; exit 1
fi
file="$FAKE/$(printf '%s' "$path" | tr '/' '_').json"
case "$method" in
  GET)
    [ -f "$file" ] || { echo "HTTP 404: Not Found" >&2; exit 1; }
    if [ -n "$jqexpr" ]; then jq -r "$jqexpr" "$file"; else cat "$file"; fi ;;
  PATCH)
    for kv in "${fields[@]}"; do
      echo "$kv" >> "$FAKE/fields"
      k="${kv%%=*}"; v="${kv#*=}"
      case "$v" in true|false) jq ".${k} = ${v}" "$file" > "$file.new" ;; *) jq --arg v "$v" ".${k} = \$v" "$file" > "$file.new" ;; esac
      mv "$file.new" "$file"
    done ;;
  PUT)
    printf '%s' "$input" | jq --argjson id "${path##*/}" '. + {id: $id, source: "o/r"}' > "$file" ;;
  POST)
    id=$((RANDOM + 1000))
    printf '%s' "$input" | jq --argjson id "$id" '. + {id: $id, source: "o/r"}' > "$FAKE/${path//\//_}_${id}.json"
    jq --argjson id "$id" --arg name "$(printf '%s' "$input" | jq -r .name)" '. + [{id: $id, name: $name}]' \
      "$FAKE/${path//\//_}.json" > "$FAKE/list.new" && mv "$FAKE/list.new" "$FAKE/${path//\//_}.json" ;;
esac
exit 0
GH
chmod +x "$tmp/bin/gh"

# A live configuration that matches the policy, shaped like GitHub's responses (extra fields included).
fixture() {
  rm -rf "$tmp/fake"; mkdir -p "$tmp/fake"; : > "$tmp/fake/log"; : > "$tmp/fake/fields"
  cat > "$tmp/fake/repos_o_r.json" <<'JSON'
{"full_name":"o/r","visibility":"public","allow_squash_merge":true,"allow_merge_commit":true,
 "allow_rebase_merge":false,"delete_branch_on_merge":true,"allow_auto_merge":true,
 "squash_merge_commit_title":"PR_TITLE","squash_merge_commit_message":"PR_BODY",
 "merge_commit_title":"PR_TITLE","merge_commit_message":"PR_BODY"}
JSON
  cat > "$tmp/fake/repos_o_r_rulesets.json" <<'JSON'
[{"id":11,"name":"develop integration policy","target":"branch","enforcement":"active"},
 {"id":12,"name":"main release policy","target":"branch","enforcement":"active"}]
JSON
  ruleset 11 "develop integration policy" develop squash \
    '[{"context":"repo-checks","integration_id":15368},{"context":"promotion-source","integration_id":15368},{"context":"standards-review"},{"context":"refusal-review"}]' \
    > "$tmp/fake/repos_o_r_rulesets_11.json"
  ruleset 12 "main release policy" main merge \
    '[{"context":"repo-checks","integration_id":15368},{"context":"promotion-source","integration_id":15368}]' \
    > "$tmp/fake/repos_o_r_rulesets_12.json"
}
ruleset() {
  jq -n --argjson id "$1" --arg name "$2" --arg ref "refs/heads/$3" --arg m "$4" --argjson c "$5" '{
    id: $id, name: $name, target: "branch", source_type: "Repository", source: "o/r",
    enforcement: "active", bypass_actors: [], current_user_can_bypass: "never", node_id: "X",
    conditions: {ref_name: {exclude: [], include: [$ref]}},
    rules: [
      {type: "deletion"}, {type: "non_fast_forward"},
      {type: "pull_request", parameters: {allowed_merge_methods: [$m], dismiss_stale_reviews_on_push: false,
        require_code_owner_review: false, require_last_push_approval: false,
        required_approving_review_count: 0, required_review_thread_resolution: false}},
      {type: "required_status_checks", parameters: {strict_required_status_checks_policy: false,
        do_not_enforce_on_create: false, required_status_checks: $c}}]}'
}
mutate() {  # mutate FILE JQ
  jq "$2" "$tmp/fake/$1" > "$tmp/fake/$1.new" && mv "$tmp/fake/$1.new" "$tmp/fake/$1"
}

run() {  # run EXPECTED NAME ARGS... — run setup-repo.sh against the fake
  local want="$1" name="$2" got=0; shift 2
  (cd "$tmp/checkout" && FAKE="$tmp/fake" PATH="$tmp/bin:$PATH" bash "$src/scripts/setup-repo.sh" "$@" >"$tmp/out" 2>&1) || got=$?
  if [ "$got" = "$want" ]; then echo "ok    $name (exit $got)"; pass=$((pass + 1))
  else echo "FAIL  $name: want exit $want, got $got"; sed 's/^/      /' "$tmp/out"; fails=$((fails + 1)); fi
}
assert() {  # assert NAME COMMAND...
  local name="$1"; shift
  if "$@"; then echo "ok    $name"; pass=$((pass + 1)); else echo "FAIL  $name"; fails=$((fails + 1)); fi
}

D=repos_o_r_rulesets_11.json

# apply runs in a scratch checkout: the script sets core.hooksPath in the checkout it runs in
git init -q "$tmp/checkout"
src_hooks_before="$(git -C "$src" config --get core.hooksPath || echo unset)"

# --check: each difference is detected ----------------------------------------------------------
fixture; run 0 "matching live settings pass" --check o/r
fixture; mutate "$D" '.conditions.ref_name.include = ["refs/heads/unrelated"]'
run 1 "ruleset on the wrong branch differs" --check o/r
fixture; mutate "$D" '.rules |= map(select(.type != "deletion"))'
run 1 "missing deletion protection differs" --check o/r
fixture; mutate "$D" '.rules |= map(select(.type != "non_fast_forward"))'
run 1 "missing force-push protection differs" --check o/r
fixture; mutate "$D" '.bypass_actors = [{"actor_id":5,"actor_type":"RepositoryRole","bypass_mode":"always"}]'
run 1 "a bypass actor differs" --check o/r
fixture; mutate "$D" '.enforcement = "evaluate"'
run 1 "an inactive ruleset differs" --check o/r
fixture; mutate "$D" '(.rules[] | select(.type == "required_status_checks") | .parameters.required_status_checks) |= map(del(.integration_id))'
run 1 "a CI check not pinned to its app differs" --check o/r
fixture; mutate "$D" '(.rules[] | select(.type == "required_status_checks") | .parameters.required_status_checks) |= map(select(.context != "refusal-review"))'
run 1 "a missing required check differs" --check o/r
fixture; mutate "$D" '(.rules[] | select(.type == "required_status_checks") | .parameters.strict_required_status_checks_policy) = true'
run 1 "an up-to-date requirement differs" --check o/r
fixture; mutate "$D" '(.rules[] | select(.type == "pull_request") | .parameters.allowed_merge_methods) = ["merge"]'
run 1 "a wrong merge method differs" --check o/r
fixture; mutate repos_o_r.json '.allow_auto_merge = false'
run 1 "auto-merge off differs" --check o/r
fixture; rm "$tmp/fake/repos_o_r_rulesets.json"
run 2 "unreadable rulesets are INCOMPLETE" --check o/r
fixture; mutate "$D" 'del(.bypass_actors)'
run 2 "bypass actors not shown is INCOMPLETE, not a match" --check o/r
fixture; mutate repos_o_r_rulesets.json 'map(select(.name != "main release policy"))'
run 1 "a missing ruleset differs" --check o/r
fixture; mutate repos_o_r_rulesets_12.json '.rules |= map(select(.type != "deletion"))'
run 1 "drift on the main ruleset differs" --check o/r
fixture; mutate repos_o_r.json '.allow_rebase_merge = true'
run 1 "a repository merge flag differs" --check o/r
fixture; mutate repos_o_r.json '.squash_merge_commit_title = "COMMIT_OR_PR_TITLE"'
run 1 "a merge commit title differs" --check o/r
fixture; mutate "$D" '(.rules[] | select(.type == "pull_request") | .parameters.require_last_push_approval) = true'
run 1 "a pull request rule parameter differs" --check o/r
fixture; mutate "$D" '(.rules[] | select(.type == "pull_request") | .parameters.dismiss_stale_reviews_on_push) = true'
run 1 "dismissing stale reviews differs" --check o/r
fixture; mutate "$D" '(.rules[] | select(.type == "pull_request") | .parameters.require_code_owner_review) = true'
run 1 "requiring code owner review differs" --check o/r
fixture; mutate "$D" '(.rules[] | select(.type == "pull_request") | .parameters.required_review_thread_resolution) = true'
run 1 "requiring review thread resolution differs" --check o/r
fixture; mutate repos_o_r.json '.merge_commit_message = "PR_TITLE"'
run 1 "a merge commit message source differs" --check o/r
fixture; mutate repos_o_r.json '.squash_merge_commit_message = "BLANK"'
run 1 "a squash commit message source differs" --check o/r
fixture; mutate repos_o_r.json '.merge_commit_title = "MERGE_MESSAGE"'
run 1 "a merge commit title source differs" --check o/r
fixture; mutate "$D" '(.rules[] | select(.type == "required_status_checks") | .parameters.do_not_enforce_on_create) = true'
run 1 "skipping checks on branch creation differs" --check o/r
fixture; mutate repos_o_r.json '.squash_merge_commit_title = "COMMIT_OR_PR_TITLE"'
run 0 "apply corrects a drifted title" o/r
assert "apply rewrote the drifted title" bash -c "[ \"\$(jq -r .squash_merge_commit_title '$tmp/fake/repos_o_r.json')\" = PR_TITLE ]"
fixture; mutate "$D" '.rules |= map(select(.type != "required_status_checks"))'; mutate repos_o_r.json '.allow_auto_merge = false'
REQUIRED_DEVELOP="" run 0 "empty REQUIRED_DEVELOP expects no checks and auto-merge off" --check o/r
fixture
REQUIRED_DEVELOP="" run 1 "empty REQUIRED_DEVELOP differs from a ruleset that requires checks" --check o/r

# apply: safe order -----------------------------------------------------------------------------
fixture
run 0 "apply with nothing to change succeeds" o/r
assert "apply with nothing to change writes nothing" \
  bash -c "! grep -q -- '--method \\(PATCH\\|PUT\\|POST\\|DELETE\\)' '$tmp/fake/log'"

fixture; mutate repos_o_r.json '.allow_auto_merge = false'
run 0 "apply over existing rulesets succeeds" o/r
assert "apply turns auto-merge off before any ruleset write" \
  bash -c "awk '/allow_auto_merge=false/{off=NR} /--method (PUT|POST)/{if(!w)w=NR} END{exit !(off && w && off < w)}' '$tmp/fake/log'"
assert "apply updates rulesets in place and never deletes one" \
  bash -c "grep -q -- '--method PUT' '$tmp/fake/log' && ! grep -q -- '--method DELETE' '$tmp/fake/log'"
assert "apply turns auto-merge on only after the rulesets" \
  bash -c "awk '/--method PUT/{w=NR} /allow_auto_merge=true/{on=NR} END{exit !(w && on && w < on)}' '$tmp/fake/log'"

fixture; mutate repos_o_r.json '.allow_auto_merge = false'
echo "HTTP 500: simulated outage" > "$tmp/fake/fail-PUT"
run 1 "a failed ruleset write fails the apply" o/r
assert "after a failed write auto-merge is never turned on" bash -c "! grep -q 'allow_auto_merge=true' '$tmp/fake/fields'"

fixture; mutate repos_o_r.json '.allow_auto_merge = false'
echo "Upgrade to GitHub Pro or make this repository public to enable this feature." > "$tmp/fake/fail-PUT"
run 0 "an unsupported plan applies the rest" o/r
assert "on an unsupported plan auto-merge stays off" bash -c "! grep -q 'allow_auto_merge=true' '$tmp/fake/fields'"

fixture; echo '[]' > "$tmp/fake/repos_o_r_rulesets.json"
run 0 "apply creates missing rulesets" o/r
assert "missing rulesets are created with POST" bash -c "grep -q -- '--method POST' '$tmp/fake/log'"

fixture; mutate repos_o_r.json '.allow_auto_merge = false'; : > "$tmp/fake/fail-GET-after-auto"
run 2 "a failed final read-back fails the apply" o/r
assert "after a failed final read-back auto-merge is turned back off" \
  bash -c "[ \"\$(jq -r .allow_auto_merge '$tmp/fake/repos_o_r.json')\" = false ]"

fixture; mutate repos_o_r.json '.allow_auto_merge = false'
AUTO_MERGE=off run 0 "AUTO_MERGE=off applies the gates with auto-merge off" o/r
assert "AUTO_MERGE=off never turns auto-merge on" bash -c "! grep -q 'allow_auto_merge=true' '$tmp/fake/fields'"
AUTO_MERGE=off run 0 "AUTO_MERGE=off --check expects auto-merge off" --check o/r

assert "the apply cases set the hook path in the scratch checkout" \
  bash -c "[ \"\$(git -C '$tmp/checkout' config --get core.hooksPath)\" = .githooks ]"
assert "the source checkout's git config is unchanged" \
  bash -c "[ \"\$(git -C '$src' config --get core.hooksPath || echo unset)\" = '$src_hooks_before' ]"

echo "passed $pass, failed $fails"
[ "$fails" = 0 ]
