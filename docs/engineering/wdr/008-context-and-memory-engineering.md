---
wdr: "008"
title: "Context & Memory Engineering"
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
  - "001"
  - "002"
tags:
  - workflow
  - agentic
---

# WDR 008: Context & Memory Engineering

**Date:** 2026-05-31
**Status:** Accepted
**Authors:** Robert Capps

---

## Executive Summary

An agent's behavior is determined by what is in its context window, and that window
is a scarce, degrading resource — accuracy falls measurably as it fills. So *what the
agent is told, and when* is itself an engineering decision. This record governs three
things: the **always-loaded context** (the `AGENTS.md` tier injected every turn) is a
budgeted resource that states durable rules and routes to records rather than
duplicating them; the **`AGENTS.md` / `CLAUDE.md` convention** is the portable, tiered
source of truth and is recorded here as a deliberate decision; and each task works
from **durable records plus an explicit scope** rather than an inherited transcript,
with deliberate handoffs between agents and phases.

---

## Table of Contents

1. Problem Context
2. Decision 1: The Always-Loaded Context Is a Budgeted Resource
3. Decision 2: The AGENTS.md / CLAUDE.md Convention Is the Portable Source of Truth
4. Decision 3: Tasks Work From Records and Scope, Not an Inherited Transcript
5. Conclusion
6. Document History

---

## 1. Problem Context

### The Problem

Two opposite failures degrade an agent, and both are about context management rather
than reasoning. The first is **bloat**: every token of always-loaded guidance
competes for attention with the task, and context measurably "rots" as it grows — a
sprawling `AGENTS.md` that accretes tips makes the agent *worse* every turn while
costing more. The second is **stale carryover**: an agent that inherits a long prior
transcript drags forward superseded conclusions and dead ends, anchoring on
intermediate states that are no longer true.

Underneath both sits an unstated convention this repository already lives but never
recorded: `AGENTS.md` as the portable source of truth, `CLAUDE.md` as a thin pointer
to it, tiered per directory. Every adopting project inherits that layout, yet nothing
explains why it is shaped that way or what belongs in it — so adopters fill it by
guess, and it drifts toward bloat.

### Requirements

1. The always-loaded tier earns its place — durable rules only, routing to records
   for the rest.
2. The doc convention is explicit, so adopters know what `AGENTS.md`/`CLAUDE.md` are
   for and what stays out.
3. A task starts from current, relevant context, not an accreted history.

### Scope

Covers the agent's context discipline: the always-loaded budget, the doc convention,
and task-scoped working context. The record corpus those docs route *to* — its
contract, selection, and freshness — is WDR 002.

---

## 2. Decision 1: The Always-Loaded Context Is a Budgeted Resource

### Decision

The always-loaded tier — the root and per-directory `AGENTS.md` injected into every
turn — is treated as a **scarce, budgeted resource**. It carries **durable rules and
routes to the records** for depth; it does **not** duplicate record bodies or accrete
tips, runbooks, and transient notes. The test for a line earning its place: *would
removing it cause a mistake?* If not, it is cut or moved to a record.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Put everything useful in AGENTS.md | Accumulate all guidance in the always-loaded files | Bloat degrades attention every turn and raises cost; "context rot" makes a fuller file a worse file |
| Duplicate record content into AGENTS.md | Copy key decisions in so the agent need not open records | Duplication drifts from the source (violates DRY, ADR 001.1); the always-loaded copy goes stale against the record |

### Rationale

1. Attention is finite and degrades with length, so the always-loaded budget is a
   real constraint, not a style preference.
2. Stating rules and routing to records keeps one source of truth (the record) and a
   thin, durable pointer (the guidance).
3. A removal test ("would cutting this cause a mistake?") gives a concrete bar for
   what belongs.

### Enforcement

Per project: keep `AGENTS.md` to durable rules + pointers; move depth into records;
periodically prune against the removal test; treat accreted tips as a smell.

---

## 3. Decision 2: The AGENTS.md / CLAUDE.md Convention Is the Portable Source of Truth

### Decision

Agent-facing documentation follows a fixed convention: **`AGENTS.md` holds the
content** (the portable, tool-agnostic source of truth); **`CLAUDE.md` is a thin
pointer** that imports it; and the docs are **tiered** — a root file for
repository-wide rules and a per-directory file scoped to that directory's concerns.
Tool-specific entry files are pointers to `AGENTS.md`, never forks of it.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Single root CLAUDE.md | One Claude-specific file at the root | Tool-locked and unscoped; every directory's rules load everywhere, and a different tool starts from nothing |
| Duplicated per-tool files | A separate full instructions file per AI tool | N copies drift apart; the same rule must be edited in every file |
| One monolithic AGENTS.md | All rules for all directories in one root file | Unscoped context loads rules irrelevant to the current directory; the file grows without bound |

### Rationale

1. Content in `AGENTS.md` with thin per-tool pointers is portable across AI tools and
   DRY — one source, many pointers.
2. Tiering scopes guidance to where it applies, which both bounds the always-loaded
   budget (Decision 1) and keeps rules near the code they govern.
3. Recording the convention explains the layout every adopter inherits, so it is
   filled deliberately rather than by guess.

### Enforcement

Per project: `AGENTS.md` as the source of truth with `CLAUDE.md` (and any other
tool's entry file) a thin import; per-directory `AGENTS.md` for local rules; this
repository ships the convention as its own example.

---

## 4. Decision 3: Tasks Work From Records and Scope, Not an Inherited Transcript

### Decision

Each unit of work starts from **durable records plus an explicit task scope**, not
from an inherited long transcript. Handoffs between agents or phases are
**deliberate, minimal summaries** — decisions made, work deferred, open questions —
and **stale intermediate conclusions are dropped** rather than carried forward. The
independent review (WDR 005) already depends on this by spawning a fresh-context
reviewer; this generalizes the principle to all agent work.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Carry the full transcript forward | Hand the next agent/phase the entire history | Drags superseded conclusions and dead ends into new work; the agent anchors on stale state |
| Start every task from zero | Discard all context between tasks | Loses the durable decisions and scope the task legitimately needs; re-derives what records already hold |

### Rationale

1. Durable records are the right long-term memory; a transcript is working memory and
   should not masquerade as the former.
2. A deliberate handoff summary preserves what matters (decisions, deferrals, open
   questions) without the noise that misleads.
3. Dropping stale conclusions prevents the compounding drift of an agent treating an
   old intermediate state as current truth.

### Enforcement

Per project: tasks scoped from records + an explicit brief; handoff/compaction
summaries that preserve decisions and modified-file/test context while dropping dead
ends; fresh context for independent review.

---

## 5. Conclusion

Context is engineered, not incidental: the always-loaded tier is budgeted to durable
rules and pointers, the `AGENTS.md`/`CLAUDE.md` convention gives that tier a portable
and tiered shape, and tasks run from current records and scope rather than an
accreted transcript. Together these keep an agent's attention on what is true and
relevant, which is the precondition for every other standard to actually be followed.
The records this guidance routes to are governed by WDR 002; concrete compaction and
summary mechanics are each adopting project's enforcement.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
