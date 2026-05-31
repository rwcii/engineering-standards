#!/usr/bin/env bash
# setup-repo.sh — reproduce this kit's branch & merge policy (WDR 010) on a GitHub repo.
#
# Most of the policy lives on GitHub (merge methods, auto-delete, branch protection),
# which a clone does NOT inherit. This script re-applies it as config-as-code, so any
# repo created or cloned from this kit reproduces the settings with one command.
# Idempotent — safe to re-run.
#
# Requires: gh (GitHub CLI) authenticated with admin on the target repo.
# Usage:    scripts/setup-repo.sh [owner/repo]      # defaults to the current repo
#
# Policy (per WDR 010): feature -> squash -> develop -> merge-commit -> main;
# never commit directly to main.
set -euo pipefail

command -v gh >/dev/null || { echo "error: GitHub CLI (gh) is required"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "error: run 'gh auth login' first"; exit 1; }

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
echo "Configuring ${REPO}"

# 1) Local hook path — blocks direct commits to main (offline, no plan needed).
if git rev-parse --git-dir >/dev/null 2>&1; then
  git config core.hooksPath .githooks
  echo "  - core.hooksPath = .githooks (pre-commit blocks direct commits to main)"
fi

# 2) Repo merge methods + auto-delete (free, any visibility).
gh api --method PATCH "repos/${REPO}" \
  -F allow_squash_merge=true -F allow_merge_commit=true -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY \
  -f merge_commit_title=PR_TITLE -f merge_commit_message=PR_BODY >/dev/null
echo "  - merge methods: squash + merge on, rebase off; auto-delete head branch on merge"

# 3) Branch-protection rulesets (require a PUBLIC repo or a paid plan: Pro/Team/Enterprise).
#    develop: PR required, squash-only merges; main: PR required, merge-commit only.
#    Both block force-pushes and branch deletion (so develop survives auto-delete).
apply_ruleset() {
  local name="$1" payload="$2" id
  id="$(gh api "repos/${REPO}/rulesets" --jq ".[] | select(.name==\"${name}\") | .id" 2>/dev/null || true)"
  [ -n "${id}" ] && gh api --method DELETE "repos/${REPO}/rulesets/${id}" >/dev/null 2>&1 || true
  # capture stderr so the caller can tell a plan limit from a real error;
  # the assignment's exit status is the gh call's exit status
  LAST_RULESET_ERR="$(printf '%s' "${payload}" | gh api --method POST "repos/${REPO}/rulesets" --input - 2>&1 >/dev/null)"
}

read -r -d '' DEVELOP_RULESET <<'JSON' || true
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

read -r -d '' MAIN_RULESET <<'JSON' || true
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

if apply_ruleset "develop integration policy" "${DEVELOP_RULESET}" \
   && apply_ruleset "main release policy" "${MAIN_RULESET}"; then
  echo "  - rulesets: develop = PR + squash-only; main = PR + merge-commit; both block force-push & deletion"
else
  case "${LAST_RULESET_ERR:-}" in
    *"Upgrade to GitHub Pro"*|*[Uu]pgrade*|*403*)
      echo "  - rulesets SKIPPED: branch protection/rulesets need a PUBLIC repo or a paid plan (Pro/Team/Enterprise)."
      echo "    Meanwhile .githooks/pre-commit + the WDR 010 convention enforce the flow." ;;
    *)
      echo "  - rulesets FAILED (re-run — a visibility change can take a moment to propagate): ${LAST_RULESET_ERR}" ;;
  esac
fi

echo "Done."
