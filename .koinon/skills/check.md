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

## Base branch
`develop`, read as `origin/develop`. A release compares `develop` with `origin/main`
(WDR 010; AGENTS.md § Working Conventions).
## Required checks
At the exact head, run these and report each check as passed, failed (with its evidence),
incomplete (it did not run, with the reason; never a pass, WDR 004 Decision 8) or not needed
(with the reason):
1. `bash scripts/check-repo.sh origin/develop`: whitespace, shell syntax, record frontmatter and
   index status, and relative links. Exit 0 passes, 1 fails, 2 is incomplete.
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
  - `git rev-parse origin/develop` equals the pin, and the pull request's head equals it;
  - `bash scripts/check-repo.sh origin/main` and `bash scripts/check-repo.test.sh`, against `main`,
    the base the release merges into;
  - `bash scripts/check-promotion-source.sh main develop <this repo> <this repo>`.
  If `develop` moves before the merge, the pin is void: cut the release again at the new commit.
## Required CI
`.github/workflows/checks.yml` runs on every pull request into `develop` or `main`, with no path
filters:
- `repo-checks`: steps 1 and 2 above, against the pull request's base, pinned to GitHub Actions.
- `promotion-source`: a pull request into `main` comes from this repository's `develop`.
The review statuses `standards-review` and `refusal-review` are posted on the exact head after each
approving verdict (docs/engineering/review/README.md § Results). `develop` requires all four
contexts; `main` requires `repo-checks` and `promotion-source` (`scripts/setup-repo.sh`).
