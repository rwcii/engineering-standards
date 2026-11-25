---
wdr: "010"
title: "Branch & Merge Flow"
status: accepted
created: "2026-05-31"
updated: "2026-11-25"
parent_wdr: ""
authors:
  - "Robert Capps"
reviewers: []
supersedes: ""
superseded_by: ""
related:
  - "004"
  - "005"
  - "006"
tags:
  - workflow
---

# WDR 010: Branch & Merge Flow

**Date:** 2026-05-31
**Status:** Accepted
**Authors:** Robert Capps

> **Project template.** Branch and merge flow is a **project-specific** decision. The universal
> WDR baseline is 001–009, and project records begin here at 010. This record is this
> repository's own flow and the worked example for adopters: the bundled tooling
> (`scripts/setup-repo.sh`, `.githooks/pre-commit`, `.github/workflows/checks.yml`) implements it.
> **Adopt it, or replace it with your own flow and adjust the tooling.** Decision 1 names the
> variants a project may choose instead.

---

## Executive Summary

Work happens on a feature branch off `develop` and is squash-merged into `develop`. A release is
one pull request from `develop` into `main`, cut at a pinned `develop` commit and merged with a
merge commit. Nothing is committed directly to `main`. Every gate and every merge binds one exact
commit: the review verdicts, the required checks, the approval and the merge all name the same
head, and the merged result is read back. Required checks gate both branches, and auto-merge is
used only where every merge gate is a required check. An up-to-date base is not required. The full
local check passes on the exact commit before a pull request opens.

---

## Table of Contents

1. Problem Context
2. Decision 1: Feature → Squash → `develop`; Release → `main`
3. Decision 2: Every Gate and Merge Binds One Exact Commit
4. Decision 3: Required Checks Gate the Merge; Auto-Merge Only When Every Gate Is Required
5. Decision 4: An Up-to-Date Base Is Not Required
6. Decision 5: A Release Merges a Pinned `develop` Commit Into `main`
7. Decision 6: The Full Local Check Passes Before a Pull Request Opens
8. Conclusion
9. Document History

---

## 1. Problem Context

### The Problem

A long-lived line that everything commits to directly drifts toward instability: a
half-finished or unreviewed change lands on the released branch, and there is no buffer
between work in progress and what is considered shippable. With agents committing at
speed, the released line needs an integration buffer and a rule that nothing reaches it
unreviewed.

Speed adds a second problem: the commit that was reviewed is not always the commit that merges.
A push after the review, a branch updated from its base, or a release cut from a moving branch
each lands content that no gate saw. Agents that open pull requests in parallel make this
common, and a gate that runs only by convention is skipped when nobody is watching.

### Requirements

1. `main` is always releasable; nothing lands on it unreviewed or directly.
2. Integration history is clean — one entry per feature.
3. The commit that merges is the commit that every gate approved.
4. A gate that blocks a merge is enforced by the host, not only by convention.
5. Parallel pull requests do not block each other only because their base moved.

### Scope

This repository's branch, merge and release policy, and the default an adopting project can take.
The review gate that this flow feeds is WDR 005; the checks are WDR 004; what an agent may do
while an approval waits is WDR 006.

---

## 2. Decision 1: Feature → Squash → `develop`; Release → `main`

### Decision

- **Feature branches** start from `develop`; all work happens there. Nothing is committed
  directly to `main`.
- A finished feature is **squash-merged into `develop`**, one commit per feature, after it passes
  the review gate (WDR 005, base `develop`) and the required checks (Decision 3).
- A release is a pull request from `develop` into `main`, merged with a **merge commit**
  (Decision 5). `main` receives only these merges; it is never committed or pushed to directly,
  and `main` is never merged back into `develop`.

A project may choose these variants instead, and records the choice in its own WDR 010:

- **Protected `main` only**: feature branches squash into `main`; Decisions 2, 3, 4 and 6 apply
  with `main` as the base, and Decision 5 does not.
- **`integration/<topic>`**: a long-running effort collects its features on an integration
  branch, which merges into `develop` as one reviewed pull request.
- **One open pull request per target**: a project that wants serial integration allows one open
  pull request into each branch at a time.
- **`release/<date>`**: a project that needs a stabilization period cuts a release branch from
  the pinned commit and fixes only on it before merging into `main`.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** Which branch flow should this repository record as its default, and which
  variants should an adopter be able to choose? The options were trunk-based work, feature
  branches straight into `main`, full Gitflow, and `develop` plus `main` with named variants.
- **Reason and scope:** `develop` keeps `main` releasable and gives integration one commit per
  feature; the variants cover small repositories and long efforts without a separate record.
  This governs this repository's flow and is the default for adopters.
- **Strength:** hard rule for this repository; default for adopters.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Trunk-based (commit to `main`) | Commit directly to `main` or via very short-lived branches | No integration buffer; an unreviewed or half-done change lands on the released line |
| GitHub flow (feature → `main`) as the default | Feature branches merge straight into `main` | No integration line to stage a batch before release; kept as the protected-`main`-only variant |
| Full Gitflow | Long-lived release and hotfix branches on top of `develop` and `main` | More ceremony than the default needs; kept as the optional `release/<date>` variant |
| Squash into `main` too | Squash-merge `develop` into `main` | Erases the lineage from `develop` to `main`; `main` loses its release points |

### Rationale

1. A `develop` buffer keeps `main` releasable: only reviewed, integrated work is promoted.
2. Squash into `develop` makes integration history one legible commit per feature.
3. "Never commit to `main`" is a single, checkable rule that protects the released line.
4. Named variants let a project change the flow without dropping the gates of Decisions 2–6.

---

## 3. Decision 2: Every Gate and Merge Binds One Exact Commit

### Decision

Each piece of gate evidence names the full hash of the commit it covers: the review verdicts,
the required checks and the approval. A push sends that commit and no other. The merge is bound
to it and refuses any other head. After the merge, the result is read back and compared with the
expected result: for a squash, its tree equals the tree of the approved head when the base had
not moved, and otherwise contains exactly the approved change; for a release, the merge commit's
second parent is the pinned commit. A new head starts the gates again; evidence for an earlier
head does not carry over.

The gates judge two trees of the same head, and the evidence says which. The reviews read the
head commit itself. CI on a pull request checks out the candidate merge of the head into its
base, so it judges the result the merge would produce. The host records the CI results on the head
commit, and the review statuses are posted there; none is posted on a test merge commit. A new head
therefore has no results until its own CI run and reviews report. The rollout check (Enforcement)
confirms where the host records them before auto-merge is turned on.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** Should the gates bind the pull request, or the exact commit? The options were to
  trust the branch name, to re-check by convention before a merge, or to bind every piece of
  evidence and the merge itself to one hash.
- **Reason and scope:** a review of one commit says nothing about another, and parallel agents
  push often. This governs every merge into `develop` and `main`.
- **Strength:** hard rule.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Bind to the pull request | Any verdict on the pull request counts for its current head | A push after the review merges content no gate saw |
| Re-check by convention | The merger looks before merging | Skipped under time pressure; no evidence of which commit was seen |

### Rationale

1. A verdict is evidence about one commit; binding it to the hash keeps it honest.
2. A head-bound merge turns "the reviewed commit merged" from a claim into a check.
3. Reading the result back catches a merge that the host composed differently than expected.

---

## 4. Decision 3: Required Checks Gate the Merge; Auto-Merge Only When Every Gate Is Required

### Decision

Each merge gate that can be expressed as a status is a **required check** on its branch, reported
on every pull request to that branch with no path filters. In this repository:

| Branch | Required checks |
| ------ | --------------- |
| `develop` | `repo-checks`, `promotion-source`, `standards-review`, `refusal-review` |
| `main` | `repo-checks`, `promotion-source` |

`repo-checks` and `promotion-source` run in CI. `standards-review` and `refusal-review` are commit
statuses posted on the exact head from each approving review report (the review procedure,
§ Results).

**Auto-merge** is allowed only where every applicable merge gate is a required check. An agent
sets it only on a pull request into `develop` whose exact head both reviews approved and whose
merge the approval or standing authorization covers; never on a release into `main`. Where a gate
is not a required check, the pull request is merged by hand once every gate passes on its head.
Without any required check, auto-merge is left off, because the host would merge at once.

A required check is only as trustworthy as whoever can report it:

- The CI checks are pinned to the CI app, so a status posted by hand under the same name does
  not satisfy them.
- Any writer can post a commit status, so the review statuses are trusted only because write
  access is limited to the accountable human and the agents acting for them. A review status
  counts only when the pull request holds the posted review summary for the same head
  (the review procedure, § Results).
- Queued auto-merge does not by itself bind a head; the review statuses do. A review status is
  posted only from an approving review of that exact head, so it is the authorization for that
  head. When a new commit is pushed after auto-merge is set, the new head has no review statuses
  and cannot merge until a review of it approves; the approval of the earlier head does not
  cover it (Decision 2). An agent that pushes a new head turns auto-merge off on that pull request
  and sets it again only after the new head's reviews approve.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** This repository had no required checks and auto-merge was off. Should auto-merge be
  enabled, and which gates should it wait for? The options were CI checks with the review verdicts
  as statuses, CI checks only, or no CI and no auto-merge.
- **Reason and scope:** with the review verdicts as statuses, the host waits for every gate, so
  auto-merge cannot pass a change that a review has not approved. This governs this repository;
  an adopter declares its own required checks.
- **Strength:** hard rule for this repository; default for adopters.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| CI checks only | Require CI; keep the review verdicts in the pull request text | Auto-merge would wait for CI alone, and the review gate would depend on convention |
| No CI, no auto-merge | Merge every approved pull request by hand | Leaves every gate to convention and the merger's attention |
| Auto-merge with no required checks | Turn auto-merge on as it is | The host merges at once; it is a direct merge with no gate |

### Rationale

1. A gate the host enforces cannot be skipped by a hurried merge.
2. Posting the verdicts as statuses puts the review gate in the same place as CI.
3. Auto-merge is safe only when the host waits for everything the merge needs.

---

## 5. Decision 4: An Up-to-Date Base Is Not Required

### Decision

A pull request does not need to include the newest commit of its base before it merges. The
required checks run on each pull request head; a conflict still stops the merge. A project that
needs an up-to-date base gets equivalent evidence another way, such as checking the candidate
merge result, and records why.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** Should the host require each branch to be up to date with its base? The options
  were on for every branch, on for `develop` only, or off.
- **Reason and scope:** with parallel pull requests, each merge puts the others out of date and
  forces an update, a new head and new gates. A release pull request is always out of date where
  `main` has the rule, because `develop` takes features by squash and never takes `main`'s merge
  commits. Updating a branch also replaces the commits that per-commit notes are attached to.
  This governs every branch of this repository and is the adopters' default.
- **Strength:** default.
- **Review when:** a merge of two separately green pull requests breaks `develop`.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Up to date on every branch | The host requires the newest base before each merge | Blocks every release pull request and serializes parallel work |
| Up to date on `develop` only | Require it where features merge | Each merge restarts the gates of every other open pull request |

---

## 6. Decision 5: A Release Merges a Pinned `develop` Commit Into `main`

### Decision

A release is one pull request from this repository's `develop` into `main`, cut at a **pinned**
`develop` commit whose required checks passed. The pull request's head must equal that commit.
Because the pull request's head is the `develop` branch, it moves when `develop` advances: the
merge is bound to the pinned commit and refuses any other head, so a release whose head has moved
does not merge. It is cut again at the new `develop` commit, with fresh evidence.
All the release evidence names it and is posted in the pull request: the required checks green
on it, the full local check run at it, and a fresh-context review of the whole `main`...`develop`
diff. The merge is bound to the pinned head and is a merge commit. The `promotion-source` check
requires the head to come from this repository's `develop`; it proves the source, and the
merge's head binding proves the pin. The local release check compares the pinned commit with
`main`, the base it merges into. After the merge, read back `main` and
confirm that its new merge commit has the pinned commit as its second parent. The tag and the
host release are created on the released merge commit, under an approval that names them.
Version numbering and release signing are each project's choice.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** How should `develop` reach `main`? The options were a merge of whatever `develop`
  holds when the merge happens, a fast-forward of `main` to a tested commit, and a release pull
  request pinned to one tested `develop` commit and merged with a merge commit.
- **Reason and scope:** pinning makes the release exactly the commit that was tested and reviewed;
  a commit that lands on `develop` afterwards cannot ride along, because the merge refuses the
  moved head. The merge commit keeps the release point on `main`. This governs releases of this repository and is the adopters' default.
- **Strength:** hard rule for this repository; default for adopters.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Merge `develop` as it stands | Merge the release pull request whenever it is ready | A feature that lands after the tests ships untested |
| Fast-forward `main` to the tested commit | Move `main` to the pinned commit with no merge commit | `main` loses its release points and needs a branch that never diverges |
| Squash pinned to the commit | One squash commit per release | `main`'s commits no longer appear in `develop`'s history |

### Rationale

1. A release is a claim about one commit; pinning makes the claim checkable.
2. The source check stops a feature branch or a fork from reaching `main` directly.
3. Creating the tag after the read-back tags what actually shipped.

---

## 7. Decision 6: The Full Local Check Passes Before a Pull Request Opens

### Decision

Before a pull request opens, the project's full local check (its check facts) passes on the exact
commit that will be pushed. A check that can run only on the host, such as one that needs the
host's settings or runners, is named as host-only in the pull request and must pass there on the
same commit. The rule applies to every pull request into `develop` or `main`.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** Should a pull request open first and let CI find the failures, or open only after
  the full local check passes? The options were CI only, a partial local check, or the full
  local check on the exact commit.
- **Reason and scope:** a pull request that fails its first check wastes review and starts the
  gates again on a new head; the local check is fast and deterministic (WDR 004). This governs
  this repository's pull requests.
- **Strength:** default.
- **Review when:** the full local check becomes too slow to run before each pull request.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| CI only | Open the pull request and let CI report | Spends a review cycle and a new head on failures found in seconds locally |
| A partial local check | Run the fast checks; leave the rest to CI | The skipped part fails on the host, with the same cost |

---

## Enforcement

The bundled tooling implements these decisions; a project that changes the flow adjusts it.

- **Rulesets:** `main` and `develop` reject direct pushes, force pushes and deletion, and require a
  pull request. `develop` merges by squash and `main` by merge commit. Each requires the checks of
  Decision 3, with the up-to-date requirement off. Merged head branches are deleted. Rulesets need
  a public repository or a paid plan; without them, the local guard and the convention carry the
  policy, and auto-merge stays off.
- **Required checks:** `.github/workflows/checks.yml` runs `repo-checks` (`scripts/check-repo.sh`,
  `scripts/check-repo.test.sh` and `scripts/setup-repo.test.sh`) and `promotion-source` (`scripts/check-promotion-source.sh`)
  on every pull request into `develop` or `main`. A pull request can change the workflow it runs,
  so a change to `.github/`, `scripts/` or `.githooks/` is a gate-document change and gets the
  stricter review of WDR 005, Decision 3.
- **Review statuses:** the review procedure (§ Results) posts `standards-review` and
  `refusal-review` on the exact head from each approving report.
- **Local guard:** `.githooks/pre-commit` blocks a direct (non-merge) commit on `main`; enable it
  once per clone with `git config core.hooksPath .githooks`.
- **Setup (config-as-code):** `scripts/setup-repo.sh` applies the merge methods, auto-delete,
  rulesets, required checks and the local hook path, updating live rulesets in place. It turns
  auto-merge on only after a read-back shows every gate in force, and fails on a partial apply.
  `scripts/setup-repo.sh --check` reads the live settings and reports each difference without
  changing anything; `scripts/setup-repo.test.sh` shows it detects each difference.
- **Rollout check:** the policy is first applied with auto-merge off (`AUTO_MERGE=off`). A probe
  pull request into `develop` then shows the gate working: it is blocked while any of the four
  checks is missing on its head, a status posted under a CI check's name by hand does not satisfy
  it, and it becomes mergeable only when all four report success on that head. Auto-merge is
  turned on only after the probe passes.
- **Review base:** the standards review and the refusal review take `develop` as their base (the
  project's check facts, `.koinon/skills/check.md`).
- **Compliance:** a merge of a commit other than the approved head, a change that lands on `main`
  other than by a release merge from `develop`, or a feature reviewed against the wrong base is a
  WDR 010 violation finding.

---

## 8. Conclusion

Changes flow feature → squash → `develop`, and a pinned `develop` commit is released into `main`
with a merge commit. Every gate and the merge name the same commit, and the result is read back.
The host enforces the gates as required checks, which is what makes auto-merge safe; an
up-to-date base is not required, and the full local check passes before a pull request opens. A
project with different needs chooses a named variant or records its own flow in this slot.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
| 2026-06-16 | Reframed as the project-specific template/worked example — recommended default flow to adopt or replace; removed sibling WDR 011 (contribution policy now lives in `CONTRIBUTING.md`) |
| 2026-10-12 | Review base and conclusion name both preflights, `standards-review` and `refusal-review` (WDR 005, Decision 4) |
| 2026-11-25 | Review base read from the project's check facts, and the conclusion names the review procedure, not local skills (WDR 008, Decision 4) |
| 2026-11-25 | Accepted. Decision 1 adds the named variants; Decisions 2–6 add exact-commit gates, required checks and auto-merge, no up-to-date base, the pinned release and the local check before a pull request |
