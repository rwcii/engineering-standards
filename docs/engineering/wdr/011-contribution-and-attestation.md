---
wdr: "011"
title: "Contribution & Attestation Policy"
status: accepted
created: "2026-05-31"
updated: "2026-05-31"
parent_wdr: ""
authors:
  - "Robert Capps"
reviewers: []
supersedes: ""
superseded_by: ""
related:
  - "009"
  - "010"
tags:
  - workflow
---

# WDR 011: Contribution & Attestation Policy

**Date:** 2026-05-31
**Status:** Accepted
**Authors:** Robert Capps

---

## Executive Summary

Now that this kit is public, MIT-licensed, and a GitHub template, it needs a stated
stance on how others engage with it — otherwise "can I send a PR?" and "who certified
that an accepted contribution may be licensed under our terms?" have no answer. This
record (the second project-specific WDR) sets that stance: there are **two supported
paths** — *fork and extend independently* (the encouraged default) or *contribute back
to the canonical kit* through a maintainer-curated, gated process — and every
contribution that lands carries a **Developer Certificate of Origin (DCO)** sign-off,
which is the contributor-side expression of WDR 009's principle that accountability
resolves to a named human.

---

## Table of Contents

1. Problem Context
2. Decision 1: Two Paths — Encouraged Fork, Curated Upstream
3. Decision 2: Accepted Contributions Carry a DCO Sign-off
4. Conclusion
5. Document History

---

## 1. Problem Context

### The Problem

A public, MIT, template repository with no contribution policy is ambiguous in two
directions. Outwardly, a would-be user cannot tell whether to fork-and-own, file an
issue, or open a pull request — and unsolicited PRs against a deliberately curated
standards kit create triage load and pressure to accept changes that dilute it.
Inwardly, a contribution that *is* accepted arrives with no explicit record that the
contributor had the right to submit it under the project's license — murky provenance
for an artifact other projects will vendor. That gap is the contributor-side version
of the very thing WDR 009 governs: accountability must resolve to a named human.

### Requirements

1. Independent reuse is frictionless — forking and extending needs no permission.
2. The canonical kit stays coherent and reviewable — what lands in *this* repo is curated.
3. The two are not conflated — "make it mine" and "improve the source" are distinct paths.
4. Every accepted contribution attests, traceably to a named human, the right to submit
   it under the project's license.

### Scope

How others engage with *this* repository and the attestation for accepted contributions.
The branch and merge mechanics a contribution follows are WDR 010; the human-accountability
principle the attestation expresses is WDR 009. Licensing terms themselves are the
`LICENSE` file (MIT).

---

## 2. Decision 1: Two Paths — Encouraged Fork, Curated Upstream

### Decision

The kit supports two engagement paths, and says so plainly:

- **Fork and extend (the encouraged default).** Anyone may fork or "Use this template,"
  run the setup script, and adapt the kit under MIT — no permission, no coordination.
  This is the expected path for most adopters, who customize enforcement to their stack
  anyway.
- **Contribute back to the canonical kit (maintainer-curated).** Changes to *this* repo
  start with an issue or discussion; pull requests are accepted **by invitation** once
  there is agreement, and follow WDR 010 (branch off `develop`, scoped change, squash
  PR) through the `standards-review` gate (WDR 005).

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Fully open PRs | Accept and triage unsolicited PRs from anyone | Triage burden, and a stream of unsolicited edits dilutes a deliberately curated standards set; the fork path already serves divergent needs without that cost |
| Take-and-adapt only | Public for reuse, but no upstream contributions at all | Forecloses genuine improvements flowing back and the community signal a public kit benefits from; an issue/discussion channel costs little |

### Rationale

1. Forking is the natural unit of reuse for a vendored, principle-level kit — adopters
   already own their enforcement, so owning their copy is the low-friction default.
2. Curating what lands in the canonical repo keeps the record set coherent, reviewable,
   and trustworthy for everyone who vendors it.
3. Separating the paths means neither gets in the other's way: reuse is permissionless,
   and the canonical line stays deliberate.

### Enforcement

Per project: `CONTRIBUTING.md` documents both paths; the repository is published as a
GitHub template (fork / "Use this template"); upstream PRs are gated by WDR 010 + the
`standards-review` preflight, and a PR template captures the curated-path checklist.

---

## 3. Decision 2: Accepted Contributions Carry a DCO Sign-off

### Decision

Every commit merged into the canonical kit carries a **Developer Certificate of Origin**
sign-off — a `Signed-off-by: Name <email>` line added with `git commit -s` — certifying
that the contributor has the right to submit the work under the project's MIT license.
This is the contributor-side expression of WDR 009: the sign-off is a statement by a
**named human**, never a bot, consistent with the cardinal no-AI/bot-attribution rule.
Forks require no sign-off — independent reuse is governed solely by MIT.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Contributor License Agreement (CLA) | Contributors sign an agreement (usually bot-gated) granting the maintainer broader rights | Heavier process and tooling, and it grants relicensing rights the project does not need — MIT already permits broad downstream reuse |
| No attestation | Rely on GitHub's inbound=outbound default (contributions are under the repo license by the platform's terms) | Leaves no explicit, per-contributor record of the right to submit — weak provenance for a kit other projects vendor, and silent on the human behind an AI-assisted change |

### Rationale

1. The DCO is near-zero friction — one signed-off line — and rides the signed-commits
   convention the repo already requires.
2. It produces a durable, human-attributable provenance trail that matches WDR 009 and
   the no-bot-attribution rule, rather than relying on an implicit platform default.
3. It is the proportionate choice for an MIT kit: real attestation without the overhead
   or relicensing scope of a CLA.

### Enforcement

Per project: `CONTRIBUTING.md` reproduces the DCO and shows `git commit -s`; the pull
request template includes a sign-off checkbox; a project may additionally wire a DCO
check (the DCO GitHub App or a CI sign-off gate) — deferred to enforcement, per the
repository's principle/enforcement split.

---

## 4. Conclusion

The kit invites two kinds of engagement — fork freely, or contribute back through a
curated, gated path — so reuse stays permissionless while the canonical line stays
deliberate. Every accepted contribution is signed off under the DCO, extending WDR 009's
human-accountability principle to outside contributors without the weight of a CLA. The
concrete sign-off enforcement (DCO app or CI check) is each project's enforcement.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
