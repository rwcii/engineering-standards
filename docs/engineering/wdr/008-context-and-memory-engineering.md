---
wdr: "008"
title: "Context & Memory Engineering"
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
  - "001"
  - "002"
  - "005"
tags:
  - workflow
  - agentic
---

# WDR 008: Context & Memory Engineering

**Date:** 2026-05-31
**Status:** Modified
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
with deliberate handoffs between agents and phases. Agent **skills come from one shared
catalog**, a repository keeps only the facts those skills read, and each agent hands off
into its own uncommitted folder. Each kind of guidance lives with the document that
serves its reader.

---

## Table of Contents

1. Problem Context
2. Decision 1: The Always-Loaded Context Is a Budgeted Resource
3. Decision 2: The AGENTS.md / CLAUDE.md Convention Is the Portable Source of Truth
4. Decision 3: Tasks Work From Records and Scope, Not an Inherited Transcript
5. Decision 4: Skills Come From One Shared Catalog; a Repository Keeps Only Its Facts
6. Decision 5: Each Agent Hands Off Into Its Own Uncommitted Folder in the Main Checkout
7. Decision 6: Each Document Has an Owner and an Audience
8. Conclusion
9. Document History

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

Underneath both sits a convention that is widely adopted but rarely recorded:
`AGENTS.md` as the portable source of truth, `CLAUDE.md` as a thin pointer to it,
tiered per directory. The layout is inherited wholesale, yet nothing explains why it
is shaped that way or what belongs in it — so it gets filled by guess, and drifts
toward bloat.

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
tool's entry file) a thin import; per-directory `AGENTS.md` for local rules.

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

## 5. Decision 4: Skills Come From One Shared Catalog; a Repository Keeps Only Its Facts

### Decision

Agent skills — the procedures for review, record writing, sprint planning, handoff and the
like — come from **one shared, versioned catalog** that is installed for the agents on a
machine. A repository does **not** keep its own copy of a skill that the catalog ships. It keeps
only a **facts file** per skill it uses: the repository's own values that the skill reads, such
as its base branch, its record folders, its check commands, and the documents that hold its
review procedure. Procedure text that is the project's own (a review lens, a check list) lives in
a tracked document that the facts file names.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** where should a repository's agent skills come from? This repository shipped its
  skills as files in the repository, linked into each agent's discovery folder, for adopters to
  copy. The shared catalog shipped newer versions of the same skills. The options were to keep
  the repository copies, to keep both, or to use the catalog with per-repository facts.
- **Reason and scope:** one copy of each shared procedure stops drift between repositories and
  stops an agent from choosing between two skills for one job. It covers the skills that the
  catalog ships. It does not cover a skill that only this project needs and the catalog does not
  ship: that skill may live in the repository. It does not cover how the decision records
  themselves are held (WDR 002, Decision 4).
- **Strength:** default. A project that cannot install the catalog keeps local skills, and says
  so in its `AGENTS.md`.
- **Review when:** the catalog stops shipping a skill that projects need, or a supported agent
  can no longer read the catalog.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Skills vendored into each repository | Each repository keeps a copy of every skill, linked into each agent's folder | Copies drift from the catalog and from each other; agents see two skills for one job and pick by wording |
| Repository copies beside the catalog | Keep both, and let the agent choose | Two procedures for one step; which one governs depends on the trigger words |
| One shared catalog plus per-repository facts | The catalog holds the procedure; the repository holds its values | Chosen |

### Rationale

1. One copy of each procedure is DRY across every repository (ADR 001.1): a fix reaches every
   adopter when the catalog updates.
2. Facts separate what is the project's own from what is shared, so the skill text stays
   generic and the repository states only what is true for it.

### Enforcement

Per project: the catalog installed for each agent family; one facts file per catalog skill the
repository uses, checked by the catalog's state report; no copy of a catalog skill committed in
the repository, unless the project uses the opt-out above. This repository realizes it with
the [Koinon](https://github.com/rwcii/koinon) catalog and the facts in `.koinon/skills/`.

---

## 6. Decision 5: Each Agent Hands Off Into Its Own Uncommitted Folder in the Main Checkout

### Decision

A session handoff (Decision 3) is written into a **folder of its own agent**, in the **main
checkout** of the repository, and is **never committed**. A resuming agent reads its own folder
first. It may read an older handoff outside that layout, such as a snapshot in a shared flat
folder, only when the maintainer names that file or the file clearly belongs to that agent, and
only to read it: new handoffs always go into the agent's own folder.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** where do session handoffs live? The options were one shared flat folder in each
  checkout, a folder per agent in the main checkout, or committed handoff files.
- **Reason and scope:** a folder per agent stops one agent from resuming another agent's work by
  mistake when several agents share a repository. The main checkout is one place that a session
  in any linked worktree can find. A handoff holds private session state, so it is not committed.
  It covers session handoffs only, not plans or records.
- **Strength:** default.
- **Review when:** the shared catalog changes its handoff layout.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| One shared flat folder per checkout | Every agent writes timestamped files into one folder | The newest file may be another agent's; each worktree has its own folder, so a session in another worktree cannot find it |
| Committed handoff files | Handoffs tracked in the repository | Publishes private session state, and adds churn to the history |
| A folder per agent in the main checkout, not committed | Chosen | Chosen |

### Enforcement

Per project: the handoff folder excluded from version control (for example in `.gitignore`);
the handoff and pickup skills read the location from the repository's facts.

---

## 7. Decision 6: Each Document Has an Owner and an Audience

### Decision

Keep guidance where its reader looks for it. Point to the document that owns a rule
when another document needs to mention it.

| Document | What belongs there |
| -------- | ------------------ |
| README | What the project is, how people use it, and links to adoption or contribution guidance. |
| Scoped `AGENTS.md` and `CLAUDE.md` | `AGENTS.md` holds operating steps, applicable gates and pointers to governing records. `CLAUDE.md` points to it as described in Decision 2. |
| Decision records | Durable choices, rationale, applicability, and the decisions they replace. |
| Skill facts | Project values the shared procedure reads, such as paths and check commands. |
| Ignored working notes and handoffs | Private session state, provisional plans and evidence used to resume work. |

A project may set budgets for its instruction files.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** Where should adoption guidance, operating rules, decisions and temporary work
  live? The options were one combined handbook, repeated guidance at each entry point,
  or documents scoped by audience with links to the owning rule.
- **Reason and scope:** Readers can find a rule without loading unrelated material. One
  owner per rule reduces drift. This governs repository guidance and session notes.
- **Review when:** readers repeatedly miss a rule or find contradictory copies.

### Alternatives Considered

| Alternative | Description | Reason declined |
| ----------- | ----------- | --------------- |
| Combined handbook | Put all guidance in one document | Loads instructions and project history into the same entry point for every reader |
| Repeat governing text | Copy the rule to each entry point | Copies drift and obscure which one governs |

### Enforcement

Review checks placement and links when guidance changes. The project names its
instruction entry points and the paths where skills find project data.

---

## 8. Conclusion

Context is engineered, not incidental: the always-loaded tier is budgeted to durable
rules and pointers, the `AGENTS.md`/`CLAUDE.md` convention gives that tier a portable
and tiered shape, and tasks run from current records and scope rather than an
accreted transcript. Together these keep an agent's attention on what is true and
relevant, which is the precondition for every other standard to actually be followed.
Each entry point serves its audience and links to the document that owns the rule.
WDR 002 governs the linked records. Concrete compaction and summary mechanics are each
adopting project's enforcement.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
| 2026-06-19 | Generalized convention wording for vendoring; removed self-referential example |
| 2026-11-25 | Decision 4: skills come from one shared catalog; a repository keeps only its facts. Decision 5: each agent hands off into its own uncommitted folder in the main checkout |
| 2026-11-25 | Decision 6 defines document roles and how to point to the owning rule. |
