# Repository facts — check

## Version
1
## Skill
check
## Sources
- AGENTS.md
- docs/engineering/wdr/010-branch-and-merge-flow.md
- .githooks/pre-commit
- .koinon/skills/record.md
- docs/engineering/wdr/007-agentic-security.md

## Base branch
`develop`, read as `origin/develop`. A release compares `develop` with `origin/main`
(WDR 010; AGENTS.md § Working Conventions).
## Required checks
This repository has no automated gate yet. At the exact head, check by hand and report each check
as passed, failed (with its evidence) or not needed (with the reason):
1. The record checks of .koinon/skills/record.md § Record checks, for each changed record.
2. The worktree is clean and the commits are signed (`git log --show-signature <base>..HEAD`).
3. `git diff --check <base>...HEAD` reports no whitespace errors.
4. The diff, the commit messages and the pull request text name no private project and quote no
   private conversation (WDR 007, Decision 4); read them in full.
## Conditional checks
- A shell script that the branch changes: check its syntax with `sh -n` or `bash -n`, as its
  shebang names.
## Required CI
None. The repository has no CI workflow; the review verdicts of docs/engineering/review/README.md
are the merge gate.
