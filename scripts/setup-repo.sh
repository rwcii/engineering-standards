#!/usr/bin/env bash
# setup-repo.sh — reproduce this kit's branch & merge policy (WDR 010) on a GitHub repo.
#
# Most of the policy lives on GitHub (merge methods, auto-delete, branch protection),
# which a clone does NOT inherit. This script re-applies it as config-as-code, so any
# repo created or cloned from this kit reproduces the settings with one command.
# Idempotent — safe to re-run.
#
# Requires: gh (GitHub CLI) authenticated with admin on the target repo (read access for --check).
# Usage:    scripts/setup-repo.sh [--check] [owner/repo]   # defaults to the current repo
#   --check   read the live settings and report each difference from this policy; change nothing.
#             Exit 0 when they match, 1 when any setting differs.
#
# Policy (per WDR 010): feature -> squash -> develop -> merge-commit -> main;
# never commit directly to main. Required checks and auto-merge per WDR 010, Decision 3.
#
# Required status contexts. Each must be reported on every pull request to that branch:
# a context that never reports blocks every merge. Override for a project with other checks:
#   REQUIRED_DEVELOP="ci-a ci-b" REQUIRED_MAIN="ci-a" scripts/setup-repo.sh
# An empty list sets no required checks; auto-merge is then left off (WDR 010, Decision 3).
REQUIRED_DEVELOP="${REQUIRED_DEVELOP-repo-checks promotion-source standards-review refusal-review}"
REQUIRED_MAIN="${REQUIRED_MAIN-repo-checks promotion-source}"
set -euo pipefail

MODE=apply
if [ "${1:-}" = "--check" ]; then MODE=check; shift; fi

command -v gh >/dev/null || { echo "error: GitHub CLI (gh) is required"; exit 1; }
command -v jq >/dev/null || { echo "error: jq is required"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "error: run 'gh auth login' first"; exit 1; }

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"

# The required_status_checks rule for a list of contexts (empty list -> no rule).
status_rule() {
  local list="$1"
  [ -n "${list// /}" ] || return 0
  printf '%s\n' ${list} | jq -R '{context: .}' | jq -s \
    '{type: "required_status_checks", parameters: {strict_required_status_checks_policy: false, do_not_enforce_on_create: false, required_status_checks: .}}'
}

AUTO_MERGE=false
[ -n "${REQUIRED_DEVELOP// /}" ] && AUTO_MERGE=true

if [ "${MODE}" = check ]; then
  echo "Checking ${REPO} (read-only)"
  drift=0
  differ() { echo "  - DIFFERS: $1"; drift=1; }
  settings="$(gh api "repos/${REPO}")"
  for pair in allow_squash_merge=true allow_merge_commit=true allow_rebase_merge=false \
              delete_branch_on_merge=true "allow_auto_merge=${AUTO_MERGE}"; do
    key="${pair%%=*}"; want="${pair#*=}"
    have="$(printf '%s' "${settings}" | jq -r ".${key}")"
    [ "${have}" = "${want}" ] || differ "${key} is ${have}, policy says ${want}"
  done
  for spec in "develop integration policy|squash|${REQUIRED_DEVELOP}" "main release policy|merge|${REQUIRED_MAIN}"; do
    name="${spec%%|*}"; rest="${spec#*|}"; method="${rest%%|*}"; contexts="${rest#*|}"
    id="$(gh api "repos/${REPO}/rulesets" --jq ".[] | select(.name==\"${name}\") | .id" 2>/dev/null || true)"
    if [ -z "${id}" ]; then differ "ruleset '${name}' is missing"; continue; fi
    rs="$(gh api "repos/${REPO}/rulesets/${id}")"
    [ "$(printf '%s' "${rs}" | jq -r .enforcement)" = active ] || differ "ruleset '${name}' is not active"
    have_method="$(printf '%s' "${rs}" | jq -r '[.rules[] | select(.type=="pull_request") | .parameters.allowed_merge_methods[]] | join(",")')"
    [ "${have_method}" = "${method}" ] || differ "ruleset '${name}' merge methods are '${have_method}', policy says '${method}'"
    have_ctx="$(printf '%s' "${rs}" | jq -r '[.rules[] | select(.type=="required_status_checks") | .parameters.required_status_checks[].context] | sort | join(" ")')"
    want_ctx="$(printf '%s\n' ${contexts} | sort | tr '\n' ' ' | sed 's/ $//')"
    [ "${have_ctx}" = "${want_ctx}" ] || differ "ruleset '${name}' requires '${have_ctx}', policy says '${want_ctx}'"
    strict="$(printf '%s' "${rs}" | jq -r '[.rules[] | select(.type=="required_status_checks") | .parameters.strict_required_status_checks_policy] | any')"
    [ "${strict}" = false ] || differ "ruleset '${name}' requires an up-to-date branch; policy says off"
  done
  if [ "${drift}" = 0 ]; then echo "  - live settings match the policy"; else exit 1; fi
  exit 0
fi

echo "Configuring ${REPO}"

# 1) Local hook path — blocks direct commits to main (offline, no plan needed).
if git rev-parse --git-dir >/dev/null 2>&1; then
  git config core.hooksPath .githooks
  echo "  - core.hooksPath = .githooks (pre-commit blocks direct commits to main)"
fi

# 2) Repo merge methods + auto-delete (free, any visibility).
gh api --method PATCH "repos/${REPO}" \
  -F allow_squash_merge=true -F allow_merge_commit=true -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true -F "allow_auto_merge=${AUTO_MERGE}" \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY \
  -f merge_commit_title=PR_TITLE -f merge_commit_message=PR_BODY >/dev/null
echo "  - merge methods: squash + merge on, rebase off; auto-delete head branch on merge; auto-merge ${AUTO_MERGE}"

# 3) Branch-protection rulesets (require a PUBLIC repo or a paid plan: Pro/Team/Enterprise).
#    develop: PR required, squash-only merges; main: PR required, merge-commit only.
#    Both block force-pushes and branch deletion (so develop survives auto-delete), and require
#    the declared status contexts, without an up-to-date branch (WDR 010, Decision 4).
apply_ruleset() {
  local name="$1" payload="$2" id
  id="$(gh api "repos/${REPO}/rulesets" --jq ".[] | select(.name==\"${name}\") | .id" 2>/dev/null || true)"
  [ -n "${id}" ] && gh api --method DELETE "repos/${REPO}/rulesets/${id}" >/dev/null 2>&1 || true
  # capture stderr so the caller can tell a plan limit from a real error;
  # the assignment's exit status is the gh call's exit status
  LAST_RULESET_ERR="$(printf '%s' "${payload}" | gh api --method POST "repos/${REPO}/rulesets" --input - 2>&1 >/dev/null)"
}

read -r -d '' DEVELOP_BASE <<'JSON' || true
{
  "name": "develop integration policy",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["refs/heads/develop"], "exclude": [] } },
  "rules": [
    { "type": "pull_request", "parameters": { "required_approving_review_count": 0, "dismiss_stale_reviews_on_push": false, "require_code_owner_review": false, "require_last_push_approval": false, "required_review_thread_resolution": false, "allowed_merge_methods": ["squash"] } },
    { "type": "non_fast_forward" },
    { "type": "deletion" }
  ]
}
JSON

read -r -d '' MAIN_BASE <<'JSON' || true
{
  "name": "main release policy",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["refs/heads/main"], "exclude": [] } },
  "rules": [
    { "type": "pull_request", "parameters": { "required_approving_review_count": 0, "dismiss_stale_reviews_on_push": false, "require_code_owner_review": false, "require_last_push_approval": false, "required_review_thread_resolution": false, "allowed_merge_methods": ["merge"] } },
    { "type": "non_fast_forward" },
    { "type": "deletion" }
  ]
}
JSON

# add the required_status_checks rule to a base ruleset
with_checks() {
  local rule; rule="$(status_rule "$2")"
  if [ -z "${rule}" ]; then printf '%s' "$1"; else printf '%s' "$1" | jq --argjson r "${rule}" '.rules += [$r]'; fi
}
DEVELOP_RULESET="$(with_checks "${DEVELOP_BASE}" "${REQUIRED_DEVELOP}")"
MAIN_RULESET="$(with_checks "${MAIN_BASE}" "${REQUIRED_MAIN}")"

if apply_ruleset "develop integration policy" "${DEVELOP_RULESET}" \
   && apply_ruleset "main release policy" "${MAIN_RULESET}"; then
  echo "  - rulesets: develop = PR + squash-only; main = PR + merge-commit; both block force-push & deletion"
  echo "  - required checks: develop = ${REQUIRED_DEVELOP:-none}; main = ${REQUIRED_MAIN:-none}"
else
  # without the rulesets no check is required, so auto-merge would merge at once
  gh api --method PATCH "repos/${REPO}" -F allow_auto_merge=false >/dev/null
  echo "  - auto-merge turned off: no ruleset requires a check"
  case "${LAST_RULESET_ERR:-}" in
    *"Upgrade to GitHub Pro"*|*[Uu]pgrade*|*403*)
      echo "  - rulesets SKIPPED: branch protection/rulesets need a PUBLIC repo or a paid plan (Pro/Team/Enterprise)."
      echo "    Meanwhile .githooks/pre-commit + the WDR 010 convention enforce the flow." ;;
    *)
      echo "  - rulesets FAILED (re-run — a visibility change can take a moment to propagate): ${LAST_RULESET_ERR}" ;;
  esac
fi

echo "Done. Verify with: scripts/setup-repo.sh --check ${REPO}"
