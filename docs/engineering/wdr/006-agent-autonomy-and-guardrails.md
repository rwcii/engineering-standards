---
wdr: "006"
title: "Agent Autonomy & Guardrails"
status: modified
created: "2026-05-31"
updated: "2026-11-25"
parent_wdr: ""
authors:
  - "Robert Capps"
reviewers: []
supersedes: ""
superseded_by: ""
related:
  - "003"
  - "007"
  - "009"
  - "010"
tags:
  - workflow
  - agentic
---

# WDR 006: Agent Autonomy & Guardrails

**Date:** 2026-05-31
**Status:** Modified
**Authors:** Robert Capps

---

## Executive Summary

An agent acts on its own between human checkpoints, and the cost of it acting wrongly
is bounded only by the guardrails around it. This record draws those bounds:
**actions are tiered by reversibility and blast radius, with the most dangerous tier
denied by default and gated on explicit authorization; every run has hard
resource ceilings that terminate it automatically; and the agent halts and hands back
on defined triggers rather than pressing through. While a decision waits for a human,
reversible work continues and the hard-to-undo steps wait.** The merge gate (WDR 005) reviews
a finished diff; it cannot stop an agent that has already force-pushed, dropped a
table, or spent the budget in a loop. These guardrails operate while the agent is
still acting.

---

## Table of Contents

1. Problem Context
2. Decision 1: Actions Are Tiered by Blast Radius; the Top Tier Is Deny-by-Default
3. Decision 2: Every Run Has Hard Resource Ceilings With Automatic Termination
4. Decision 3: The Agent Halts and Escalates on Defined Triggers
5. Decision 4: While a Decision Waits, Reversible Work Continues
6. Conclusion
7. Document History

---

## 1. Problem Context

### The Problem

The merge gate and independent review are **merge-time** controls — they inspect a
proposed change before it lands. But an agent does consequential things *during* its
run that never reach a diff: it runs shell commands, calls tools, deletes files,
pushes branches, mutates data, spends money on model calls. A review cannot undo a
dropped production table or a force-push, and it never sees the eleven broken
attempts the agent thrashed through before the twelfth.

Three failures follow from unbounded autonomy. The agent performs an **irreversible
action** it should have asked about first. It enters a **runaway loop** — a real
incident saw a multi-agent pipeline loop for eleven days and bill tens of thousands
of dollars — because nothing forced it to stop. And it **never escalates**: faced
with ambiguity or repeated failure, it presses on with a confident guess instead of
handing back to a human. The dangerous failure is not stopping too often; it is not
stopping at all.

### Requirements

1. The blast radius of an autonomous action is bounded by what tier it falls in.
2. A run cannot consume unbounded time, iterations, or money.
3. There are explicit conditions under which the agent must stop and ask.

### Scope

Covers autonomy boundaries, resource ceilings, and escalation triggers. The hermetic
sandbox and capability/network limits that *contain* what an action can reach are WDR
007; the merge-time gate is WDR 005.

---

## 2. Decision 1: Actions Are Tiered by Blast Radius; the Top Tier Is Deny-by-Default

### Decision

Actions are classified by **reversibility and blast radius** into tiers — for
example: auto-allowed (safe, reversible, repo-scoped reads and edits); gated
(notable but recoverable); and never-without-confirmation (irreversible or
high-blast-radius: destructive data operations, force-push, production mutations,
spending, publishing). The top tier is **deny-by-default** and proceeds only on
explicit authorization — a real-time human confirmation when a human is in the loop,
or, for autonomous operation, a pre-authorization recorded in the principal's mandate
(WDR 009); absent either, the agent halts (Decision 3). Permissions follow
least-privilege.

**Gate crossed:** agent-time.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Full autonomy | The agent may take any action it deems necessary | One wrong irreversible action has unbounded cost; no human is in the loop where it matters most |
| Confirm everything | Gate every action on human approval | Destroys the throughput that makes agents useful; humans rubber-stamp under volume, so the gate stops meaning anything |
| Allowlist by tool name only | Permit/deny by which tool, ignoring impact | The same tool spans tiers (a shell can `ls` or `rm -rf`); tiering by blast radius is what actually bounds risk |

### Rationale

1. Tiering puts the human checkpoint exactly where the cost of being wrong is
   highest, and nowhere it adds only friction.
2. Deny-by-default at the top tier means a novel dangerous action is blocked, not
   permitted by omission.
3. Reversibility is the right axis: it is precisely the irreversible actions a review
   cannot save you from.

### Enforcement

Per project: a documented action-tier mapping; permission/allowlist config that
denies the top tier by default and requires confirmation; least-privilege defaults
(read-only where possible, scoped credentials).

---

## 3. Decision 2: Every Run Has Hard Resource Ceilings With Automatic Termination

### Decision

Every agent run operates under **hard ceilings that terminate it automatically** — a
per-run budget (cost and/or tokens), a maximum iteration count, and loop detection.
When a ceiling is reached, the run **stops**; a human is notified. Resource **alerts
are not enforcement** — the ceiling must actually halt the run, not merely warn.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Budget alerts only | Warn when usage is high | A warning does not stop a runaway loop; the bill accrues while no one is watching |
| Trust the agent to stop | Rely on the agent to detect it is stuck | A looping agent is the least able to notice it is looping; self-policing fails exactly when needed |
| No ceiling | Let runs go until they finish or a human intervenes | The "$47k loop" — an unbounded run can burn time and money without limit |

### Rationale

1. A hard ceiling converts an unbounded tail risk into a known, capped cost.
2. Automatic termination does not depend on a human noticing in time.
3. Loop detection catches the failure mode (repeating with no progress) that a raw
   budget alone would let run to the limit.

### Enforcement

Per project: a governance layer that enforces per-run cost/token ceilings and an
iteration cap with automatic termination; a loop detector; a human paged on breach.
The concrete limits are project-specific.

---

## 4. Decision 3: The Agent Halts and Escalates on Defined Triggers

### Decision

The agent **stops and hands back to a human** — rather than pressing on — on defined
triggers: ambiguous or conflicting requirements; an apparent conflict with an
accepted record; a decision that itself warrants a new record; an irreversible or
destructive operation (per Decision 1); or repeated failed self-correction on the
same problem. Escalation is a first-class, expected outcome, not a failure.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Always find a way | The agent resolves every blocker itself | Barreling through ambiguity with a guess, or thrashing on an unsolvable problem, is worse than asking |
| Escalate only on error | Hand back only when something throws | Misses the dangerous cases (ambiguity, silent conflict with a record) where nothing errors but the agent is off-track |

### Rationale

1. Naming the triggers makes escalation a rule an agent applies, not an instinct it
   lacks.
2. Halting on conflict-with-a-record routes a real decision to a human (and possibly
   a new record) instead of an unilateral agent call.
3. A cap on repeated self-correction bounds the cost of an unsolvable task.

### Enforcement

Per project: the trigger set enumerated for the agent; a stop-and-ask path that
surfaces the blocker with context; a self-correction attempt cap that escalates
rather than loops.

---

## 5. Decision 4: While a Decision Waits, Reversible Work Continues

### Decision

When the agent has asked a human for a decision (Decision 3) and the answer has not come:

- It continues independent work that is already authorized.
- It continues reversible work on the option it recommended, on its work branch only.
- These wait for the decision: a merge, a push to a base branch, a release, a settings change, a
  deletion, a change to a live host or production, and any external or paid action.
- When the decision picks another option, the agent discards or reverts the branch work on the
  recommended option, without asking again.
- A pending request alone does not authorize work outside the assigned task, and it does not stop
  unrelated work.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** What may an agent do while a decision it asked for is pending? The options were to
  stop all dependent work, to continue only work that needs no new authority, or to continue
  reversible work on the recommended option while the hard-to-undo steps wait.
- **Reason and scope:** decisions can wait for hours, and branch work is cheap to discard; the
  steps that are hard to undo still wait, so the decision keeps its authority. This governs every
  pending decision an agent has asked for, through any channel.
- **Strength:** default.
- **Review when:** discarded work on a declined option becomes a recurring cost.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Stop dependent work until the decision | Pause everything that relates to the pending question | Idle hours on work that is cheap to discard |
| Continue only work that needs no new authority | Wait for the decision before building a proposed choice that needs it; the hard-to-undo steps follow their own authorization rules | Keeps the decision ahead of the build, but idles the agent on the recommended path, and differs from the practice several projects already follow |

### Enforcement

Per project: the list of waiting actions in the agent instructions; the base branches protected so
a push or merge needs its own authorization (WDR 010).

---

## 6. Conclusion

Autonomy is made safe by bounding it: tier actions by blast radius and deny the
dangerous tier by default, cap every run with ceilings that terminate it
automatically, and require the agent to halt and ask on defined triggers. While the answer is
pending, reversible work continues and the hard-to-undo steps wait. These are
agent-time guardrails — they act while the agent is still working, where the
merge-time review (WDR 005) cannot reach — and they pair with the containment the
execution sandbox provides (WDR 007). Concrete tiers, budgets, limits, and triggers
are each adopting project's enforcement.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
| 2026-11-25 | Decision 4: work while a decision waits |
