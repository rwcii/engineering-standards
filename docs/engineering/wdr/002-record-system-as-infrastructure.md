---
wdr: "002"
title: "Record System as Infrastructure"
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
  - "008"
tags:
  - workflow
  - agentic
---

# WDR 002: Record System as Infrastructure

**Date:** 2026-05-31
**Status:** Modified
**Authors:** Robert Capps

---

## Executive Summary

The decision records are not just documentation for humans to read occasionally —
they are the **interface an agent consults every time it changes the system**, the
thing the standards review validates against, and the memory that keeps a
part-human, part-agent team from re-litigating settled decisions. For that to hold
at scale, the record set must behave like infrastructure: machine-readable,
selectable, internally consistent, and kept current.

This record establishes three properties of the record system itself: its
frontmatter is a **machine-readable contract** (with the human-facing index
generated from it, never hand-maintained); records carry **applicability metadata**
so the governing set is *selected by narrowing* rather than read in full; and the
record graph maintains **referential integrity and freshness**, so a stale or
orphaned record is a defect, not background noise. A project that adopts shared records
**copies them or cites them against a pinned list**, never through a live link.

---

## Table of Contents

1. Problem Context
2. Decision 1: Frontmatter Is a Machine-Readable Contract; the Index Is Generated
3. Decision 2: Records Are Selected by Applicability, Not Read Wholesale
4. Decision 3: The Record Graph Stays Referentially Sound and Current
5. Decision 4: Shared Records Are Copied or Cited Against a Pinned List
6. Conclusion
7. Document History

---

## 1. Problem Context

### The Problem

A record set that works at five records breaks at fifty. Three failures appear as
the corpus grows, and each one bites an agent harder than a human:

- **The index drifts from the records.** A hand-maintained index can say
  `accepted` while the record itself says `superseded`. A human notices the
  mismatch; an agent trusts the index literally.
- **"Read everything" stops scaling.** A protocol that says "read every record in
  full" is a context-window time bomb: it is already many thousands of words in an
  empty skeleton and grows without bound in every adopting project.
- **The graph rots silently.** A cross-reference points at a number that no longer
  exists; a superseding record is not reciprocated; an accepted record is
  contradicted by a later change that never updates it. The agent retrieves the
  stale record as current truth and reproduces a superseded pattern, defending it
  as compliant.

The common thread: an agent's primary interface to this system is the
**frontmatter and the link graph**, not the prose. If that interface is
inconsistent, unselectable, or stale, every downstream decision inherits the error.

### Requirements

1. The machine-readable metadata is canonical and authoritative; human-facing
   catalogs derive from it.
2. The relevant records for a given change can be **selected** without reading the
   whole corpus.
3. Cross-references and statuses are internally consistent, and contradictions
   between code and an accepted record surface as defects.

### Scope

Covers the record system as agent-facing infrastructure — the contract, selection,
and integrity of records across all three types (ADR/PDR/WDR). It does not define
the classification of decisions among the types (WDR 001) or the contents of any
individual standard.

---

## 2. Decision 1: Frontmatter Is a Machine-Readable Contract; the Index Is Generated

### Decision

Each record's YAML frontmatter is a **contract**: a defined field set with types,
required/optional rules, a status enum, and a closed tag vocabulary, against which
every record validates. The human-facing index (the `README.md` tables) is
**generated from the frontmatter**, not maintained by hand — a record's appearance
in the catalog is derived, so the catalog cannot disagree with the record.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Hand-maintained index | Authors edit the README table when adding or changing a record | Index and record drift apart; a human-edited catalog silently lies about status |
| Prose-only records, no schema | Treat records as free-form documents | Nothing to validate against; an agent cannot reliably parse or filter the corpus |

### Rationale

1. One authoritative source (the frontmatter) with a derived catalog is the DRY
   standard (ADR 001.1) applied to the record system — the same "generate, don't
   hand-duplicate" rule the architecture already holds.
2. A validated contract lets tooling reject a malformed record before it reaches
   review.
3. A stable, typed interface is what makes every other agent-facing operation on
   the corpus (selection, integrity checks) possible.

### Enforcement

Per project: a published frontmatter schema; a validator run in the gate; a
generator that builds each index from frontmatter, and a check that fails when the
committed index is stale relative to the records. Until a project wires that generator,
the index is hand-maintained as a tracked stopgap kept honest by the staleness check —
hand-maintenance is the rejected *steady state*, not a forbidden interim.

---

## 3. Decision 2: Records Are Selected by Applicability, Not Read Wholesale

### Decision

Records carry **machine-filterable applicability metadata** — tags, scope, and what
they apply to (by area, layer, or change type) — and the canonical way to find the
governing set for a change is to **filter the index and frontmatter first, then
deep-read only the selected records**. "Read every record in full" is replaced by
"select the applicable records, then read those."

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Read every record every time | A reviewer ingests the entire corpus per run | Does not scale; exhausts the context window and degrades attention as the corpus grows per adopter |
| Manual curation per review | A human picks the relevant records each time | Not reproducible; an agent cannot apply it unattended; the selection is re-derived from scratch each run |

### Rationale

1. Selection by metadata is deterministic and reproducible — an agent narrows the
   same way every time.
2. It bounds the cost of a review by the *relevant* corpus, not the total corpus,
   which is the only way the gate survives a real adopting project.
3. It is the natural substrate for fanning a large review out across the relevant
   records rather than the whole set.

### Enforcement

Per project: an applicability convention in the frontmatter (e.g., tags and
path/area scope); an index filter as the canonical entry point; the standards review
narrows to the applicable records before deep-reading.

---

## 4. Decision 3: The Record Graph Stays Referentially Sound and Current

### Decision

The records form a graph whose edges must resolve and whose contents must track the
system they govern:

- Every referenced record number resolves; supersession is reciprocal (the
  superseded record points back); a point version's parent exists; fields a status
  requires are present.
- A change that **contradicts an accepted record must update or supersede that
  record in the same change.** A change that contradicts an accepted record without
  touching it is a defect.
- A significant change **cites the record that governs it**, and that record is
  discoverable from the code; a significant change governed by no record is itself a
  signal that a record — or an update to one — is missing.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Best-effort links | Treat cross-references and statuses as informal | Dangling references and stale "accepted" records mislead an agent that reads them as current truth |
| Periodic manual audit | Sweep the corpus for rot occasionally | Drift accrues between sweeps; the agent acts on stale records in the meantime |

### Rationale

1. An agent retrieves records as authoritative memory; a stale record is actively
   misleading and compounds turn over turn.
2. Reciprocal, resolvable links let the graph be traversed and validated
   mechanically.
3. Tying contradiction-without-update to a finding turns the lifecycle the process
   docs already define into an enforceable obligation — which is what actually
   prevents drift.

### Enforcement

Per project: link-graph and status invariants checked in the gate; a
the standards review finding when a change contradicts an accepted record without
updating it, or when a significant change cites no governing record.

---

## 5. Decision 4: Shared Records Are Copied or Cited Against a Pinned List

### Decision

A project that adopts records from a shared source holds them in one of two ways:

- **Copy:** the project copies the records into its own repository and owns them from there.
- **Cite against a pinned list:** the records stay in one source repository. The project cites
  each record it relies on, and a check compares each citation with a list of the source's
  records pinned at a known version, so a citation to a record that does not exist fails.

A project does not hold shared records through a live link that follows the source's latest
state, such as a submodule or an unpinned reference.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** how does an adopting project hold the shared records? The options were to copy
  them, to cite them against a pinned list, or to link them live with a submodule.
- **Reason and scope:** a copy suits a project that adapts the records; a pinned citation suits
  a family of repositories that share one source and must not drift from it. A live link changes
  a project's rules without a change in the project. It covers decision records only; skills are
  WDR 008, Decision 4.
- **Strength:** default.
- **Review when:** a project needs a third way that neither form serves.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Copy only | Every project copies the records | A family of repositories that share one source gets many drifting copies |
| Live link (submodule or unpinned reference) | The project follows the source's latest state | The project's rules change without a reviewed change in the project |
| Copy, or cite against a pinned list | Chosen | Chosen |

### Enforcement

Per project: a copied set follows its own process documents; a cited set has a check that fails
a citation missing from the pinned list, and moves the pin only in a reviewed change.

---

## 6. Conclusion

Treated as infrastructure, the record set is machine-readable (a frontmatter
contract with a generated index), selectable (applicability metadata, narrow before
deep-read), and sound (a referentially consistent graph kept current with the code).
These properties are what let the records serve as an agent's interface and memory
at scale, and what let the standards review validate against them without reading the
entire corpus. The concrete schema, validator, generator, and filters are each
adopting project's enforcement.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
| 2026-11-25 | Decision 4: shared records are copied or cited against a pinned list; the review is named as the standards review, not a local skill |
