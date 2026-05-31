---
wdr: "003"
title: "Agent Operating Loop"
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
  - "004"
  - "005"
tags:
  - workflow
  - agentic
---

# WDR 003: Agent Operating Loop

**Date:** 2026-05-31
**Status:** Accepted
**Authors:** Robert Capps

---

## Executive Summary

A human engineer carries the goal in their head, orients before acting, and knows
by instinct when the work is done. An autonomous agent has none of that: it will
pattern-match a fix before understanding the system, stop at the first
plausible-looking state, declare success without running anything, and — under
pressure to turn the signal green — fake the result rather than fix the cause.

This record defines the loop every unit of agent work follows: **establish context
and a plan before mutating; bind the task to a pre-stated definition of done;
establish completion by execution and observed evidence, not assertion, resolving
failures at their root rather than gaming the signal; and stay within the task's
scope.** It governs *how the agent arrives at* a change — the front of the pipeline
that the structural standards (ADR 001) and the merge gate never see.

---

## Table of Contents

1. Problem Context
2. Decision 1: Discovery and a Stated Plan Precede Mutation
3. Decision 2: A Pre-Stated Definition of Done Bounds the Task
4. Decision 3: Completion Is Established by Execution, and Failure Is Resolved, Not Gamed
5. Decision 4: Changes Stay Within the Task's Scope
6. Conclusion
7. Document History

---

## 1. Problem Context

### The Problem

The characteristic failures of agent-driven work are not structural — they are
procedural, and they cluster at the two ends of a task:

- **At the start:** the agent edits before it understands, "fixing" code it never
  read and breaking a boundary it was never told about; it acts on an unverified
  assumption as if it were fact.
- **At the end:** it declares completion against no stated target, claims success
  it never observed, and — when a check goes red — takes the cheapest path to green,
  which is often to suppress the check rather than fix the code.

None of this is caught by standards that judge the *shape* of the resulting code. A
diff can satisfy every architectural rule and still solve the wrong problem,
half-finish it, or pass only because the test was neutered. The loop itself must be
governed.

### Requirements

1. A change follows from an articulated understanding and plan, not improvisation.
2. Every task has an explicit, checkable target before work begins.
3. Completion is demonstrated by observed execution, and failing evidence is
   resolved at its cause.
4. The change's blast radius is bounded to what the task requires.

### Scope

Covers the agent's working procedure for a unit of work. Test integrity and the
gate's contents are WDR 004; the independent review that follows the loop is WDR
005; when to halt and escalate is WDR 006.

---

## 2. Decision 1: Discovery and a Stated Plan Precede Mutation

### Decision

Before mutating code, the agent establishes enough context to act safely — reading
the relevant code paths and records — and the change follows from an **articulated
plan**, not from improvisation. Beliefs the plan rests on are **verified against the
code or explicitly flagged as assumptions**; an unverified belief is never acted on
as if it were fact. The plan is the artifact the resulting diff is checked against.

**Gate crossed:** agent-time (before edits).

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Edit-first, fix-as-you-go | Begin changing code immediately, discover the system through trial and error | Produces changes that solve the wrong problem or break unread boundaries; the agent's bias to act makes this the default failure mode |
| Plan only for "big" tasks | Skip planning for changes that look small | "Small" is judged before understanding; the threshold hides exactly the changes that turn out to be large |

### Rationale

1. Orienting first is what a human does by instinct and an agent must be told to do.
2. A stated plan gives both the reviewer and the agent's own self-check something to
   measure the diff against.
3. Verifying or flagging assumptions converts invisible guesses into either facts or
   surfaced risks a human can adjudicate.

### Enforcement

Per project: a planning step proportional to the change; surfacing the plan before
large edits; review that checks the diff against the stated plan and intent.

---

## 3. Decision 2: A Pre-Stated Definition of Done Bounds the Task

### Decision

Each unit of work is bound, **before editing begins**, to an explicit **Definition
of Done**: the checkable acceptance criteria the change must satisfy, derived from
the request. The agent may not declare completion until each criterion is met with
evidence. The definition of done is the task's *target*; it is distinct from the
merge gate's pass/fail line (WDR 005), which is the project's *floor*.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Implicit "done when it looks right" | Let the agent judge completion by feel | An agent has no internal goal anchor; it stops at the first plausible state or over-builds past the ask |
| Define done only at review time | Discover the acceptance criteria when reviewing the diff | The target is then set after the work, so the work cannot have converged on it; under- and over-shooting surface late |

### Rationale

1. A stated target is the agent's missing termination condition — the principled
   reason to stop, neither early nor late.
2. Checkable criteria turn "I think it's done" into "each criterion is met, here is
   the evidence."
3. Set before editing, the definition shapes the work rather than rationalizing it
   afterward.

### Enforcement

Per project: acceptance criteria captured at task start (issue, plan, or spec); a
completion check that the criteria are met before the work is offered for review.

---

## 4. Decision 3: Completion Is Established by Execution, and Failure Is Resolved, Not Gamed

### Decision

A change is "done" only when its definition of done is demonstrated by **actually
running the relevant checks and observing the result** — the same gate the
project's CI runs, against real boundaries, with the genuine output shown rather
than asserted or recalled from memory. When a check goes **red**, the agent resolves
the failure at its **root cause**. It is forbidden from making the signal pass by
illegitimate means — deleting or skipping the check, loosening an assertion to
triviality, swallowing an error, weakening a type, or hardcoding the expected
result. (Test-integrity specifics are WDR 004.)

**Gate crossed:** agent-time (before commit).

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Assert success from reasoning | Conclude the change works because the logic looks right | Fluent text is cheaper to produce than a real run; unexecuted "success" is the signature agent failure |
| Agent-only shortcut checks | Verify with a lighter check than CI runs | "Passed for me, failed in CI"; only running the real gate makes completion reproducible |
| Any green counts | Accept a passing signal however it was achieved | Rewards suppressing the check over fixing the code; a gamed green is worse than an honest red |

### Rationale

1. Observed evidence is the only completion signal that a fresh reviewer can
   independently re-run.
2. Running the same gate as CI makes "done" mean the same thing for the agent and
   the pipeline.
3. Forbidding signal-gaming is what makes "run the checks" meaningful rather than
   trivially satisfiable.

### Enforcement

Per project: the single pre-merge gate command (ADR 001) is the verification gate;
captured output backs completion claims; review flags any disabled or weakened check
in the diff.

---

## 5. Decision 4: Changes Stay Within the Task's Scope

### Decision

The agent confines its changes to what the task requires. Unrequested refactors,
opportunistic rewrites, drive-by reformatting, and unrelated "improvements" are not
bundled in. Out-of-scope work the agent believes is warranted is **surfaced and
deferred**, not silently performed.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Tidy while you're in there | Let the agent improve adjacent code opportunistically | Agents have near-zero marginal cost to touch many files; sprawling diffs bury the intended change, defeat review, and entangle unrelated risk |
| Bundle related cleanups | Fold "obviously good" nearby changes into the same change | Defers the judgment of "related" to the agent; revert and bisect stop being viable safety nets |

### Rationale

1. A bounded diff is legible — a reviewer can see what the change does and why.
2. Bounded changes keep revert a viable safety net when something goes wrong.
3. Surfacing deferred work preserves the idea without inflating the current change.

### Enforcement

Per project: review that flags changes outside the task's stated scope; deferred
work tracked as its own item rather than absorbed silently.

---

## 6. Conclusion

The operating loop governs how an agent arrives at a change: orient and plan before
mutating, fix the target with a definition of done, prove completion by execution
while resolving — never gaming — failing evidence, and hold the change to its scope.
These procedural controls address the agent failure modes that structural standards
cannot see, and they hand a bounded, verified, plan-aligned change to the
independent review (WDR 005). Concrete planning artifacts, gate commands, and
tracking mechanisms are each adopting project's enforcement.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
