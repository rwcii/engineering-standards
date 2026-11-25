#!/usr/bin/env bash
# setup-repo.sh — reproduce this kit's branch & merge policy (WDR 010) on a GitHub repo.
#
# Most of the policy lives on GitHub (merge methods, auto-delete, rulesets, required checks,
# auto-merge), which a clone does NOT inherit. This script applies it as config-as-code and reads
# it back. Idempotent — safe to re-run.
#
# Requires: gh (GitHub CLI) authenticated with admin on the target repo, and jq. --check needs admin
#           too: GitHub returns a ruleset's bypass actors only to a caller who can edit it, and
#           --check reports INCOMPLETE when they are not returned.
# Usage:    scripts/setup-repo.sh [--check] [owner/repo]   # defaults to the current repo
#   --check   read the live settings and report each difference from this policy; change nothing.
#
# Exit status: 0 the live settings match the policy (for an apply on a plan without rulesets: the
# rest was applied, with auto-merge off); 1 a setting differs or an apply step failed; 2 the
# settings could not be read in full. On a plan without rulesets, --check reports them missing (1).
#
# Policy (WDR 010): feature -> squash -> develop; a pinned develop commit -> merge commit -> main;
# never commit directly to main. Required checks and auto-merge: WDR 010, Decision 3.
#
# Required status checks, as NAME or NAME@APP_ID. With @APP_ID the ruleset accepts the result
# only from that GitHub App (15368 is GitHub Actions), so a status posted by hand cannot stand in
# for CI. Each check must report on every pull request to its branch, or it blocks every merge.
# Override for a project with other checks:
#   REQUIRED_DEVELOP="build@15368 test@15368" REQUIRED_MAIN="build@15368" scripts/setup-repo.sh
# An empty REQUIRED_DEVELOP sets no required checks on develop and leaves auto-merge off.
#
# AUTO_MERGE=off applies everything else and keeps auto-merge off (and --check then expects it
# off). A first rollout is staged — first without promotion-source, which cannot run until the
# default branch carries its workflow — as WDR 010, Enforcement (Bootstrap and rollout check) says.
REQUIRED_DEVELOP="${REQUIRED_DEVELOP-repo-checks@15368 promotion-source@15368 standards-review refusal-review}"
REQUIRED_MAIN="${REQUIRED_MAIN-repo-checks@15368 promotion-source@15368}"
set -uo pipefail

MODE=apply
if [ "${1:-}" = "--check" ]; then MODE=check; shift; fi

command -v gh >/dev/null || { echo "error: GitHub CLI (gh) is required"; exit 2; }
command -v jq >/dev/null || { echo "error: jq is required"; exit 2; }
gh auth status >/dev/null 2>&1 || { echo "error: run 'gh auth login' first"; exit 2; }

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}" || { echo "error: cannot resolve the repository"; exit 2; }
WANT_AUTO_MERGE=false
[ -n "${REQUIRED_DEVELOP// /}" ] && [ "${AUTO_MERGE:-on}" != off ] && WANT_AUTO_MERGE=true

RULESETS="develop integration policy|develop|squash|${REQUIRED_DEVELOP}
main release policy|main|merge|${REQUIRED_MAIN}"

# desired_ruleset NAME BRANCH METHOD CONTEXTS — the ruleset payload this policy wants.
desired_ruleset() {
  local checks
  checks="$(printf '%s\n' $4 | jq -R 'select(length > 0) | split("@") |
    if length > 1 then {context: .[0], integration_id: (.[1] | tonumber)} else {context: .[0]} end' | jq -s .)"
  jq -n --arg name "$1" --arg ref "refs/heads/$2" --arg method "$3" --argjson checks "$checks" '{
    name: $name, target: "branch", enforcement: "active", bypass_actors: [],
    conditions: {ref_name: {include: [$ref], exclude: []}},
    rules: ([
      {type: "pull_request", parameters: {required_approving_review_count: 0,
        dismiss_stale_reviews_on_push: false, require_code_owner_review: false,
        require_last_push_approval: false, required_review_thread_resolution: false,
        allowed_merge_methods: [$method]}},
      {type: "non_fast_forward"},
      {type: "deletion"}
    ] + (if ($checks | length) > 0 then [{type: "required_status_checks", parameters: {
        strict_required_status_checks_policy: false, do_not_enforce_on_create: false,
        required_status_checks: $checks}}] else [] end))}'
}

# canonical — the fields this policy governs, in a comparable form (live or desired ruleset).
canonical() {
  jq -S '{target, enforcement, bypass: (.bypass_actors // []),
    include: (.conditions.ref_name.include // []), exclude: (.conditions.ref_name.exclude // []),
    rules: ([.rules[] |
      if .type == "pull_request" then {type, methods: (.parameters.allowed_merge_methods | sort),
        approvals: .parameters.required_approving_review_count,
        dismiss_stale: .parameters.dismiss_stale_reviews_on_push,
        code_owner: .parameters.require_code_owner_review,
        last_push: .parameters.require_last_push_approval,
        thread_resolution: .parameters.required_review_thread_resolution}
      elif .type == "required_status_checks" then {type,
        strict: .parameters.strict_required_status_checks_policy,
        enforce_on_create: (.parameters.do_not_enforce_on_create // false | not),
        checks: ([.parameters.required_status_checks[] |
          .context + (if .integration_id then "@" + (.integration_id | tostring) else "" end)] | sort)}
      else {type} end] | sort_by(.type))}'
}

# ruleset_id NAME — the id of the live ruleset with that name (empty if none); fails on API error.
ruleset_id() {
  gh api "repos/${REPO}/rulesets" --jq ".[] | select(.name==\"$1\") | .id"
}

# verify AUTO_MERGE — compare the live settings with the policy. 0 match, 1 differ, 2 unreadable.
verify() {
  local want_auto="$1" drift=0 settings pair key want have line name branch rest method contexts id live
  settings="$(gh api "repos/${REPO}")" || { echo "  - INCOMPLETE: cannot read the repository settings"; return 2; }
  for pair in allow_squash_merge=true allow_merge_commit=true allow_rebase_merge=false \
              delete_branch_on_merge=true "allow_auto_merge=${want_auto}" \
              squash_merge_commit_title=PR_TITLE squash_merge_commit_message=PR_BODY \
              merge_commit_title=PR_TITLE merge_commit_message=PR_BODY; do
    key="${pair%%=*}"; want="${pair#*=}"
    have="$(printf '%s' "${settings}" | jq -r ".${key}")"
    [ "${have}" = "${want}" ] || { echo "  - DIFFERS: ${key} is ${have}, policy says ${want}"; drift=1; }
  done
  while IFS= read -r line; do
    name="${line%%|*}"; rest="${line#*|}"; branch="${rest%%|*}"; rest="${rest#*|}"
    method="${rest%%|*}"; contexts="${rest#*|}"
    id="$(ruleset_id "${name}")" || { echo "  - INCOMPLETE: cannot list the rulesets"; return 2; }
    if [ -z "${id}" ]; then echo "  - DIFFERS: ruleset '${name}' is missing"; drift=1; continue; fi
    live="$(gh api "repos/${REPO}/rulesets/${id}")" || { echo "  - INCOMPLETE: cannot read ruleset '${name}'"; return 2; }
    # an absent field is not "no bypass actors": GitHub omits it for a caller who cannot edit it
    if [ "$(printf '%s' "${live}" | jq 'has("bypass_actors")')" != true ]; then
      echo "  - INCOMPLETE: ruleset '${name}' does not show its bypass actors (admin access needed)"
      return 2
    fi
    want="$(desired_ruleset "${name}" "${branch}" "${method}" "${contexts}" | canonical)"
    have="$(printf '%s' "${live}" | canonical)"
    if [ "${have}" != "${want}" ]; then
      echo "  - DIFFERS: ruleset '${name}':"
      diff <(printf '%s\n' "${want}") <(printf '%s\n' "${have}") | sed -n 's/^</      policy:/p; s/^>/      live:  /p'
      drift=1
    fi
  done <<< "${RULESETS}"
  return "${drift}"
}

if [ "${MODE}" = check ]; then
  echo "Checking ${REPO} (read-only)"
  verify "${WANT_AUTO_MERGE}"; status=$?
  [ "${status}" = 0 ] && echo "  - live settings match the policy"
  exit "${status}"
fi

echo "Configuring ${REPO}"

# 1) Local hook path — blocks direct commits to main (offline, no plan needed).
if git rev-parse --git-dir >/dev/null 2>&1; then
  git config core.hooksPath .githooks
  echo "  - core.hooksPath = .githooks (pre-commit blocks direct commits to main)"
fi

# Nothing to change: leave the live settings alone (no auto-merge off/on cycle).
if verify "${WANT_AUTO_MERGE}" >/dev/null; then
  echo "Done: the live settings already match the policy; nothing changed."
  exit 0
fi

# 2) Merge methods and auto-delete, with auto-merge OFF until the gates are proven in force.
gh api --method PATCH "repos/${REPO}" \
  -F allow_squash_merge=true -F allow_merge_commit=true -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true -F allow_auto_merge=false \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY \
  -f merge_commit_title=PR_TITLE -f merge_commit_message=PR_BODY >/dev/null \
  || { echo "  - FAILED: repository merge settings"; exit 1; }
echo "  - merge methods: squash + merge on, rebase off; auto-delete head branch on merge; auto-merge off"

# 3) Rulesets, updated in place (a live gate is never deleted first). They need a PUBLIC repo or a
#    paid plan (Pro/Team/Enterprise).
unsupported=0; failed=0
while IFS= read -r line; do
  name="${line%%|*}"; rest="${line#*|}"; branch="${rest%%|*}"; rest="${rest#*|}"
  method="${rest%%|*}"; contexts="${rest#*|}"
  payload="$(desired_ruleset "${name}" "${branch}" "${method}" "${contexts}")"
  if ! id="$(ruleset_id "${name}" 2>&1)"; then
    err="${id}"
  elif [ -n "${id}" ]; then
    err="$(printf '%s' "${payload}" | gh api --method PUT "repos/${REPO}/rulesets/${id}" --input - 2>&1 >/dev/null)" && err=""
  else
    err="$(printf '%s' "${payload}" | gh api --method POST "repos/${REPO}/rulesets" --input - 2>&1 >/dev/null)" && err=""
  fi
  if [ -z "${err}" ]; then
    echo "  - ruleset '${name}': ${branch}, ${method} only, PR required, no force-push or deletion, checks: ${contexts:-none}"
  else
    case "${err}" in
      *"Upgrade to GitHub Pro"*|*"upgrade"*|*"Upgrade"*) unsupported=1
        echo "  - ruleset '${name}' SKIPPED: rulesets need a PUBLIC repo or a paid plan" ;;
      *) failed=1; echo "  - ruleset '${name}' FAILED: ${err}" ;;
    esac
  fi
done <<< "${RULESETS}"

if [ "${failed}" = 1 ]; then
  echo "Apply incomplete: a ruleset failed; auto-merge stays off. Fix the error and re-run."
  exit 1
fi
if [ "${unsupported}" = 1 ]; then
  echo "Rulesets are unavailable on this plan: .githooks/pre-commit and the WDR 010 convention carry"
  echo "the policy, and auto-merge stays off because no check is required."
  exit 0
fi

# 4) Read back; turn auto-merge on only when every gate is proven in force.
verify false; status=$?
[ "${status}" = 0 ] || { echo "Apply incomplete: the read-back differs; auto-merge stays off."; exit "${status}"; }
if [ "${WANT_AUTO_MERGE}" = false ]; then
  echo "Done: the live settings match the policy; auto-merge is off."
  exit 0
fi
auto_merge_off() {
  gh api --method PATCH "repos/${REPO}" -F allow_auto_merge=false >/dev/null \
    && echo "  - auto-merge turned back off" \
    || echo "  - WARNING: could not turn auto-merge back off; turn it off by hand"
}
if ! gh api --method PATCH "repos/${REPO}" -F allow_auto_merge=true >/dev/null; then
  echo "  - FAILED: turning auto-merge on"; auto_merge_off; exit 1
fi
echo "  - auto-merge on (develop requires: ${REQUIRED_DEVELOP})"
verify true; status=$?
if [ "${status}" != 0 ]; then
  echo "Apply incomplete: the final read-back did not confirm the policy."
  auto_merge_off
  exit "${status}"
fi
echo "Done: the live settings match the policy."
