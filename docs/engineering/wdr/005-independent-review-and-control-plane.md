---
wdr: "005"
title: "Independent Review & Control-Plane Protection"
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
  - "002"
  - "003"
  - "004"
tags:
  - workflow
  - agentic
---

# WDR 005: Independent Review & Control-Plane Protection

**Date:** 2026-05-31
**Status:** Accepted
**Authors:** Robert Capps

---

## Executive Summary

The single most load-bearing safeguard in this repository is that a change is
reviewed by an **independent agent** before it merges — a reviewer with no stake in,
and no context from, the work that produced it. That idea lives today only as an
instruction inside `standards-review`; it deserves to be the recorded decision that
command derives from. This record establishes three things: review independence as a
hard requirement; a **defined merge-gate contract** (a severity taxonomy, what
blocks versus advises, and how an override is justified) so author and reviewer
cannot simply disagree on severity; and **heightened protection for the control
plane** — the records, gates, and review machinery that judge every other change.

---

## Table of Contents

1. Problem Context
2. Decision 1: Significant Changes Pass an Independent Review Before Merge
3. Decision 2: The Merge Gate Has a Defined Pass/Fail Contract
4. Decision 3: Changes to the Control Plane Get Heightened Review
5. Conclusion
6. Document History

---

## 1. Problem Context

### The Problem

Self-review by the author who just wrote the change is the weakest review there is —
the author shares every blind spot and assumption that produced the work. With
agents the problem sharpens: the authoring agent has a context full of the reasoning
that justified the change and will tend to confirm it. A fresh reviewer that sees
only the diff, not the reasoning, is the one that catches what the author could not.

Two further gaps undermine even an independent review. If "what blocks a merge" is
undefined, author and reviewer disagree on severity with no tiebreak, and the gate's
verdict becomes negotiable. And nothing today protects the **control plane** itself:
the records, CI guards, hooks, and `standards-review` are what judge every change,
yet an agent can weaken the very guard that would catch its change — in the same
diff — and nothing flags it.

### Requirements

1. A change is judged by someone other than its author, without the author's context.
2. "Pass" and "fail" are defined, not improvised per change.
3. Changes that alter the judging machinery are held to a higher bar than the
   changes it judges.

### Scope

Covers the review gate and protection of the control plane. The agent's own
pre-review verification is WDR 003; test integrity feeding the gate is WDR 004; the
review protocol's concrete steps live in `standards-review`.

---

## 2. Decision 1: Significant Changes Pass an Independent Review Before Merge

### Decision

A significant change is reviewed, before merge, by an **independent** reviewer: not
the author, sharing no working context with the change, treating the author's claims
as **unverified** until checked against the code, and holding an adversarial stance.
The reviewer's job is to find what is wrong, not to confirm what is right. Review is
**scoped** to correctness, requirements, and compliance with the records — a reviewer
told to "find everything" manufactures noise, and chasing findings below a real
threshold drives over-engineering.

**Gate crossed:** merge-time.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Author self-review | The author re-reads their own change | Shares the author's blind spots; with an agent, the producing context biases toward confirmation |
| Same-context reviewer | A reviewer primed with the authoring conversation | Inherits the reasoning that justified the change and re-confirms it instead of testing it |
| Unbounded "find everything" review | Report every conceivable issue | Manufactures low-value findings and pushes the change toward over-engineering; dilutes the real findings |

### Rationale

1. A fresh-context reviewer sees the diff, not the story behind it — the only vantage
   that catches confirmation-shaped errors.
2. Treating author claims as unverified is the agent-era analogue of "trust, but
   verify" — necessary because fluent justification is cheap.
3. Scoping review keeps it a quality gate rather than a generator of busywork.

### Enforcement

Per project: `standards-review` spawned as a fresh-context agent before push/PR;
the reviewer reads the actual code and verifies claims; review bounded to
correctness, requirements, and record compliance.

---

## 3. Decision 2: The Merge Gate Has a Defined Pass/Fail Contract

### Decision

The merge gate has an explicit contract: a **severity taxonomy** (e.g.,
critical/high/medium/low/note), a rule for which severities **block** versus merely
**advise**, and a **waiver protocol** — an override is allowed only with a recorded
justification and the right approver, never silently. The verdict links to the
merge: a blocking finding stops the merge until resolved or waived.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Severity by feel | Reviewer labels severity ad hoc, no defined scale | Author and reviewer disagree with no tiebreak; the gate's verdict becomes negotiable |
| Block on everything | Any finding blocks merge | Conflates notes with defects; the gate becomes an obstacle people route around |
| Silent overrides | Allow merging past findings without record | A weakened gate with no trail; the override cannot be reviewed or learned from |

### Rationale

1. A defined scale makes "does this block?" answerable the same way every time —
   which an agent needs to act unattended.
2. A waiver-with-justification keeps the gate firm while leaving a deliberate,
   reviewable escape hatch for genuine exceptions.
3. `standards-review` already emits severities and a recommendation; defining the
   taxonomy is what makes that output binding rather than advisory.

### Enforcement

Per project: a documented severity scale and blocking rule (the universal default:
do not approve with any critical or high finding); a waiver mechanism that records
the justification and approver; the gate wired to the verdict.

---

## 4. Decision 3: Changes to the Control Plane Get Heightened Review

### Decision

The **control plane** — the decision records, CI guards, hooks, the review protocol,
and enforcement configuration — is what judges every other change, so changes to it
are held to a higher bar. Weakening, disabling, or removing a check is a
**high-severity, must-justify** event, and a change to the gate is reviewed by
someone (or some agent) **other than the party weakening it**. The judge may not be
quietly edited by the change it would judge.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Treat gate config like any code | Review control-plane changes at normal severity | The most direct merge-optimizing shortcut is to weaken the guard that blocks you; normal review misses it because the guard is the thing under review |
| Freeze the control plane | Forbid changes to gates/records | Gates must evolve; freezing them drives workarounds and rots the kit |

### Rationale

1. The control plane is leverage: a single weakened guard silently lowers the bar for
   every future change.
2. Requiring a different reviewer for gate changes closes the "weaken the judge in
   the same diff" loophole.
3. This repository *is* a control plane, so the rule protects the kit itself as much
   as any adopting project.

### Enforcement

Per project: review treats any loosened/disabled check or altered gate as
high-severity requiring explicit justification; control-plane changes routed to a
reviewer other than the author; the freshness obligation (WDR 002) applies to records
changed here.

---

## 5. Conclusion

Independent review is the safeguard the whole kit rests on: a fresh, adversarial
reviewer judges the change against a defined pass/fail contract, and changes to the
judging machinery itself are held higher than the changes they judge. This is the
merge-time counterpart to the agent-time operating loop (WDR 003) and testing
discipline (WDR 004): the agent verifies its own work, then an independent reviewer
verifies it again with no shared context. The concrete review protocol, severity
scale, waiver mechanism, and control-plane guards are each adopting project's
enforcement, with `standards-review` as the reference implementation.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
