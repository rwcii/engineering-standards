---
wdr: "001"
title: "Decision-Record Taxonomy & the WDR Series"
status: accepted
created: "2026-05-31"
updated: "2026-05-31"
parent_wdr: ""
authors:
  - "Robert Capps"
reviewers: []
supersedes: ""
superseded_by: ""
related: []
tags:
  - workflow
  - agentic
---

# WDR 001: Decision-Record Taxonomy & the WDR Series

**Date:** 2026-05-31
**Status:** Accepted
**Authors:** Robert Capps

---

## Executive Summary

This repository governs decisions with two record types: ADRs (how the system is
*built*) and PDRs (how the product *behaves*). A third class of decision fits
neither: decisions about **how the work is done** — the engineering workflow, the
agent operating loop, the review and enforcement gates, and the record system
itself. These survive both a complete rewrite and a complete product pivot, so they
have no home in a two-type taxonomy and today leak into `AGENTS.md` as ungoverned
guidance.

This record establishes a third type — the **Workflow Decision Record (WDR)** — as
a separate numbered series that **reuses the ADR template, lifecycle, and review
path**. It also defines the procedure for classifying any decision as an ADR, a
PDR, or a WDR. ADRs are thereby kept purely architectural; workflow decisions gain a
first-class, compliance-checkable home without a parallel set of machinery to
maintain.

---

## Table of Contents

1. Problem Context
2. Decision 1: Adopt the WDR as a Third Record Type
3. Decision 2: The ADR / PDR / WDR Classification Procedure
4. Conclusion
5. Document History

---

## 1. Problem Context

### The Problem

The taxonomy here rests on a clean rule of thumb: a decision that survives a
complete rewrite (new language, new framework) is a **PDR** — it is about product
behavior, independent of technology; a decision that survives a complete product
pivot (new features, new flows) is an **ADR** — it is about how the system is built,
independent of the product.

The most consequential decisions in agent-driven engineering satisfy *both* tests
at once. "Every change passes an independent review before merge," "the agent
verifies its work by execution and observed evidence, not assertion," "the agent
halts and asks before an irreversible action," and "the `AGENTS.md` / `CLAUDE.md`
layout is the portable, tiered source of truth" — none of these change in a rewrite
or in a pivot, because they govern *how the team and its agents work*, not what is
built or how it behaves.

A two-type taxonomy cannot file its own most important governance. These decisions
therefore land in `AGENTS.md` as always-loaded guidance — the wrong instrument:
guidance is advice the reader may weigh, whereas these are settled decisions with
real alternatives that the team anchors on and validates compliance against. They
deserve to be records.

### Requirements

1. A first-class home for decisions about how the work is done — anchorable and
   compliance-checkable, the same standing as an ADR.
2. The architectural record set stays uncluttered, so what an ADR *is* — a meaty
   architectural decision — is not diluted as workflow decisions multiply.
3. A deterministic procedure for routing any decision to exactly one record type,
   so equivalent decisions do not scatter across ADR / PDR / `AGENTS.md`.
4. Minimal new machinery, because this kit is vendored into other projects and
   every new mechanism is maintenance each adopter inherits.

### Scope

Covers the addition of a third record type and the rule for classifying decisions
among the three. It does not define the record system's machine-readable contract
or its retrieval and freshness mechanics — those are a separate decision (a planned
WDR on the record system as infrastructure).

---

## 2. Decision 1: Adopt the WDR as a Third Record Type

### Decision

Add the **Workflow Decision Record (WDR)** as a third record type, living in
`docs/engineering/wdr/` as its own number series starting at 001. A WDR documents a
significant decision about how the work is done: the engineering workflow, the agent
operating loop, the review and enforcement gates, and the record system itself.

The WDR **reuses the ADR machinery** rather than inventing its own — the same
template, the same `draft → under_review → accepted → modified →
deprecated/superseded` lifecycle, the same cardinal rules, and the same
`standards-review` path (which gains a WDR-compliance phase). Only the *scope* and
the frontmatter key (`wdr`/`parent_wdr`, plus the `workflow`/`agentic` tags) differ.
ADR scope is unchanged and remains strictly architectural.

### Alternatives Considered

| Alternative                                | Description                                                                                  | Why Rejected                                                                                                                                                                                                                                                                                                          |
| ------------------------------------------ | -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Broaden ADR to "built **and** maintained"  | Keep one series; file workflow decisions as ADRs in a reserved number range with a `workflow` tag | Dilutes what an ADR is: the workflow corpus is larger and grows faster than the architectural one, so it would soon swamp the architecture signal in the same series — the failure named in the field as "if every decision is architectural, no decision is architectural." It also forces a future renumber if the classes ever split, breaking cross-references in every project that vendored the kit. |
| Standalone third type with its own machinery | A parallel type with its own template, process, lifecycle, and review phase                | Cleanest separation but the highest maintenance: a second template and process to keep in sync with the ADR one, multiplied across every adopting project. The separation benefit is obtainable without the duplication.                                                                                              |
| Status quo — `AGENTS.md` guidance          | Leave workflow decisions as always-loaded guidance                                           | `AGENTS.md` is advice, not an anchorable decision-with-alternatives validated at review. Guidance decays and cannot be checked for compliance; these decisions are too consequential to leave ungoverned.                                                                                                             |

### Rationale

1. A separate series keeps ADRs purely architectural, so the architecture set stays
   legible even as workflow records accumulate.
2. A separate series owns its numbering from the start, so no future split forces a
   renumber that breaks vendored cross-references.
3. Reusing the ADR template, lifecycle, and review path captures the separation
   benefit at near-zero added machinery — the DRY standard (ADR 001.1) applied to
   the record system itself.
4. Workflow decisions become anchorable and compliance-checkable, the standing the
   requirements demand.

### Trade-offs Accepted

- One more directory and index for adopters to understand and keep current.
- A decision occasionally sits near the ADR/WDR boundary and needs the
  classification procedure (Decision 2) to route deterministically.

---

## 3. Decision 2: The ADR / PDR / WDR Classification Procedure

### Decision

Every decision that warrants a record is routed by two gates.

**The altitude gate (shared by all three types).** A record captures a *meaty
decision with genuine alternatives* the team anchors on and validates compliance
against. A rule with no real alternative, or a tip rather than a decision, is not a
record — it belongs in an `AGENTS.md` working-convention or a project's enforcement.

**The type test (three questions).**

1. Would the decision change in a complete **rewrite** (new language/framework)?
   → it is about how the system is built → **ADR**.
2. Would it change in a complete **product pivot** (new features/flows)?
   → it is about how the product behaves → **PDR**.
3. Does it survive **both** — because it governs how the team and its agents work?
   → **WDR**.

A decision that survives both a rewrite and a pivot is a WDR. The record system, the
review loop, and the agent operating procedure are WDR territory by this test.

### Alternatives Considered

| Alternative                  | Description                                       | Why Rejected                                                                                                                                                  |
| ---------------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Author's judgment per decision | Let each contributor decide the type by feel    | A human can muddle an ambiguous boundary; an agent filing a record needs a mechanical rule, or equivalent decisions scatter across types and fragment compliance lookups |
| Route by subject-matter keyword | Classify by topic (e.g., "security → ADR")     | Topic does not determine type — a security *threat-model* decision is architectural, a security *review-gate* decision is workflow; the rewrite/pivot test separates them correctly |

### Rationale

1. The two-gate procedure is deterministic enough for an agent to apply unattended,
   which is the point — agents file records and must route them the same way every
   time.
2. The altitude gate keeps all three series free of tips and how-tos, preserving the
   "decision with genuine alternatives" bar the repository already holds.
3. The rewrite/pivot test extends the taxonomy's existing rule of thumb rather than
   replacing it, so the addition is continuous with how the repo already reasons.

---

## 4. Conclusion

The repository now governs decisions with three record types: ADRs for how the
system is built, PDRs for how the product behaves, and WDRs for how the work is done.
The WDR is a separate series that reuses the ADR template, lifecycle, and review path,
so workflow decisions gain a first-class, compliance-checkable home while ADRs stay
purely architectural and adopters inherit almost no new machinery. A two-gate
classification procedure — an altitude gate plus the rewrite/pivot test — routes any
decision to exactly one type, deterministically enough for an agent to apply.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
