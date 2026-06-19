---
wdr: "010"
title: "Branch & Merge Flow"
status: draft
created: "2026-05-31"
updated: "2026-06-16"
parent_wdr: ""
authors:
  - "Robert Capps"
reviewers: []
supersedes: ""
superseded_by: ""
related:
  - "005"
tags:
  - workflow
---

# WDR 010: Branch & Merge Flow

**Date:** 2026-05-31
**Status:** Draft (template)
**Authors:** Robert Capps

> **Template.** Branch and merge flow is a **project-specific** decision — the universal
> WDR baseline is 001–009, and project records begin here at 010. This record is the
> *worked example* of a project-specific WDR: it states a recommended default flow that
> the kit's bundled tooling (`scripts/setup-repo.sh`, `.githooks/pre-commit`) already
> implements. **Adopt it as your flow, or replace it with your own and adjust the
> tooling**, then set `status: accepted`. The decision and rationale below describe the
> default — keep what fits, rewrite what doesn't.

---

## Executive Summary

This record fixes how changes flow from a working branch to the released line. The
recommended default: **work happens on a feature branch off `develop`; the feature is
squash-merged into `develop`; `develop` is merged into `main` with a real merge commit;
and nothing is ever committed directly to `main`.** The flow keeps `main` stable and
releasable, gives `develop` a clean one-commit-per-feature history, and preserves real
release points on `main`. A project with different constraints records its own flow here.

---

## Table of Contents

1. Problem Context
2. Decision: Feature → squash → `develop` → merge → `main`
3. Conclusion
4. Document History

---

## 1. Problem Context

### The Problem

A long-lived line that everything commits to directly drifts toward instability: a
half-finished or unreviewed change lands on the released branch, and there is no buffer
between work-in-progress and what is considered shippable. With agents committing at
speed, the released line needs an integration buffer and a hard rule that nothing
reaches it unreviewed.

At the same time, history matters two different ways. The *integration* line wants to
read as one clean entry per feature, not the dozens of intermediate commits a feature
accumulates. The *released* line wants to preserve genuine release points — when a
batch of integrated work was promoted — as real merge commits, so the lineage from
integration to release is legible.

### Requirements

1. `main` is always releasable; nothing lands on it unreviewed or directly.
2. Integration history is clean — one entry per feature.
3. Release points from integration to released are preserved as real merges.

### Scope

A project's branch and merge policy. This is a project-specific decision — each adopting
project chooses its own; the universal review gate this flow feeds is WDR 005.

---

## 2. Decision: Feature → squash → `develop` → merge → `main`

### Decision

The recommended default flow:

- **Feature branches** are cut from `develop`; all work happens there. Nothing is
  committed directly to `main`.
- A finished feature is **squash-merged into `develop`** — one clean commit per feature
  — after passing the independent review gate (WDR 005, base `develop`).
- `develop` is promoted to `main` with a **regular merge commit** (no squash), so the
  release point and the develop→main lineage are preserved.
- `main` receives **only** merge commits from `develop`; it is never committed to or
  pushed to directly.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Trunk-based (commit to `main`) | Commit directly to `main` or via very short-lived branches | No integration buffer; an unreviewed or half-done change lands on the released line — the exact thing to prevent |
| GitHub flow (feature → `main`) | Feature branches merge straight into `main`, no `develop` | No integration line to stage and validate a batch before release; `main` absorbs every feature directly |
| Full Gitflow (release/hotfix branches) | Add long-lived release and hotfix branches on top of develop/main | More ceremony than this default needs; release/hotfix branches add machinery without a matching problem |
| Squash into `main` too | Squash-merge `develop` into `main` as well | Erases the develop→main release lineage; `main` loses real merge/release points |

### Rationale

1. A `develop` buffer keeps `main` releasable: only reviewed, integrated work is
   promoted.
2. Squash into `develop` makes integration history one legible commit per feature.
3. A regular merge into `main` preserves genuine release points and the lineage
   between the two lines.
4. "Never commit to `main`" is a single, checkable rule that protects the released line
   by construction.

### Enforcement

The bundled tooling implements this default; a project that changes the flow adjusts it.

- **Branch protection (remote):** `main` and `develop` reject direct pushes and require
  a reviewed pull request; `develop`'s merge method is squash, `main`'s is a merge
  commit. Merged head branches auto-delete (a protected `develop` is exempt). GitHub
  rulesets/branch protection require a public repo or a paid plan; absent that, the
  local guard and the convention carry the policy.
- **Local guard:** a committed `pre-commit` hook (`.githooks/pre-commit`) blocks a
  direct (non-merge) commit on `main`; enable it once per clone with
  `git config core.hooksPath .githooks`.
- **Review base:** `standards-review` defaults its base branch to `develop`, so a
  feature is reviewed against what it will merge into.
- **Setup (config-as-code):** `scripts/setup-repo.sh` re-applies the GitHub settings
  above (merge methods, auto-delete, rulesets) and the local hook path, so a cloned or
  newly created repo reproduces this policy with one command.
- **Compliance:** a change that lands on `main` other than by a merge from `develop`,
  or a feature reviewed against the wrong base, is a WDR-010 violation finding.

---

## 3. Conclusion

The recommended default flows feature → squash → `develop` → merge → `main`, and `main`
is never committed to directly. The `develop` buffer keeps the released line stable,
squash keeps integration history clean, and the regular merge to `main` preserves real
release points. Enforcement is branch protection plus a local commit guard, with
`standards-review` reviewing each feature against `develop`. A project with different
needs records its own flow in this slot.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
| 2026-06-16 | Reframed as the project-specific template/worked example — recommended default flow to adopt or replace; removed sibling WDR 011 (contribution policy now lives in `CONTRIBUTING.md`) |
