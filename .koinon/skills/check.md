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
- docs/engineering/wdr/004-verification-and-testing-discipline.md
- docs/engineering/review/README.md
- scripts/check-repo.sh
- scripts/check-repo.test.sh
- scripts/check-promotion-source.sh
- scripts/setup-repo.sh
- scripts/setup-repo.test.sh
- .github/workflows/checks.yml
- .github/workflows/promotion-source.yml

## Base branch
`develop`, read as `origin/develop`. A release compares `develop` with `origin/main`
(WDR 010; AGENTS.md § Working Conventions).
## Required checks
At the exact head, run these and report each check as passed, failed (with its evidence),
incomplete (it did not run, with the reason; never a pass, WDR 004 Decision 8) or not needed
(with the reason):
1. `bash scripts/check-repo.sh <base>`, where `<base>` is the pull request's base: `origin/develop`
   for a feature, `origin/main` for a release. It checks whitespace, shell syntax, record
   frontmatter and index status, and relative links. Exit 0 passes, 1 fails, 2 is incomplete.
2. `bash scripts/check-repo.test.sh` and `bash scripts/setup-repo.test.sh`: each check above, the
   promotion-source check and the settings check fail on a seeded defect.
3. The record checks of .koinon/skills/record.md § Record checks that the script does not cover,
   for each changed record.
4. The worktree is clean and the commits are signed (`git log --show-signature <base>..HEAD`).
5. The diff, the commit messages and the pull request text name no private project (WDR 007,
   Decision 4); read them in full. This check stays manual: the list of names is not published.
## Conditional checks
- A change to `scripts/setup-repo.sh`: `bash scripts/setup-repo.test.sh`.
- A release pull request into `main` (WDR 010, Decision 5), at the pinned commit:
  - `git rev-parse origin/develop` equals the pin, and
    `gh pr view <number> --json headRefOid -q .headRefOid` equals it too;
  - the pull request's real source passes:
    `bash scripts/check-promotion-source.sh main "$(gh pr view <number> --json headRefName -q .headRefName)" "$(gh pr view <number> --json headRepositoryOwner,headRepository -q '.headRepositoryOwner.login + "/" + .headRepository.name')" "$(gh repo view --json nameWithOwner -q .nameWithOwner)"`.
  If `develop` moves before the merge, the pin is void: cut the release again at the new commit.
- After a merge (bound to the approved head with `--match-head-commit`, WDR 010 Enforcement), read
  back the merge commit that the pull request records, not the branch tip:
  `m=$(gh pr view <number> --json mergeCommit -q .mergeCommit.oid)`, then `git fetch origin`.
  For a feature, the squash's tree is the expected candidate for its actual first parent:
  `git rev-parse <m>^{tree}` equals `git merge-tree --write-tree <m>^ <approved head>` (Git 2.38 or
  later); when `<m>^` is an ancestor of the approved head, it also equals
  `git rev-parse <approved head>^{tree}`.
  For a release, `git rev-parse <m>^2` is the pin.
## Required CI
On every pull request into `develop` or `main`, with no path filters, and again when its base
changes:
- `repo-checks` (`.github/workflows/checks.yml`): steps 1 and 2 above, on the candidate merge.
- `promotion-source` (`.github/workflows/promotion-source.yml`): runs from the base branch; a pull
  request into `main` comes from this repository's `develop`.
The review statuses are posted on the exact head after each approving verdict
(docs/engineering/review/README.md § Results). Which contexts each branch requires is declared in
`scripts/setup-repo.sh` and decided in WDR 010, Decision 3.
