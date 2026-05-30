---
adr: "001"
title: "Code Architecture Standards"
status: accepted
created: "2026-05-30"
updated: "2026-05-30"
parent_adr: ""
authors:
  - "Robert Capps"
reviewers: []
supersedes: ""
superseded_by: ""
related:
  - "001.1"
  - "001.2"
  - "001.3"
  - "001.4"
  - "001.5"
tags:
  - architecture
  - enforcement
---

# ADR 001: Code Architecture Standards

**Date:** 2026-05-30
**Status:** Accepted
**Authors:** Robert Capps

---

## Executive Summary

Any codebase developed over time by multiple contributors — human or AI — accrues
architectural decay unless deliberate standards hold it in check: duplication,
hidden coupling, brittle extension points, leaky abstractions, and configuration
drift. This ADR establishes five code-architecture standards that govern production
code, each with a dedicated point-version ADR:

| Point ADR | Standard                     |
| --------- | ---------------------------- |
| 001.1     | DRY — Don't Repeat Yourself   |
| 001.2     | Modular Architecture         |
| 001.3     | Extensible by Construction   |
| 001.4     | Interface Boundaries         |
| 001.5     | Centralized Configuration    |

The standards are stated as **principles**. The concrete enforcement — lint rules,
CI guards, codegen, type checks, build gates — is supplied by each adopting project
for its own stack and recorded in that project's copy of these records.

---

## Table of Contents

1. Problem Context
2. Decision 1: Adopt Five Code Architecture Standards
3. Decision 2: Enforce Through Layered Automated Checks
4. Alternatives Considered
5. Conclusion
6. Document History

---

## 1. Problem Context

### The Problem

Multi-contributor codebases tend toward five recurring forms of decay:

- **Duplication** — the same logic, constants, or types copied across modules and
  drifting apart.
- **Tight coupling** — units reaching into each other's internals, so changes
  cascade unpredictably.
- **Brittle extension points** — adding a variant (a provider, an object type, a
  tier) requires touching many files.
- **Leaky abstractions** — units exposing implementation details, creating implicit
  dependencies the compiler cannot catch.
- **Configuration drift** — settings scattered across files, hardcoded constants, and
  ad-hoc copies with no single source of truth.

These are amplified by AI-assisted development, where a generated change can satisfy
the immediate requirement while violating a boundary it was never told about.

### Requirements

1. Standards concrete enough that both human reviewers and AI agents apply them consistently.
2. Violations caught automatically where possible, not left to manual review alone.
3. Standards that reinforce each other rather than conflict.
4. Compliance overhead proportional to benefit — no ceremony for its own sake.

### Scope

This ADR covers the selection and rationale for the five standards. Each standard's
definition, patterns, and enforcement live in its point-version ADR (001.1–001.5).

---

## 2. Decision 1: Adopt Five Code Architecture Standards

### Decision

All production code conforms to five standards:

1. **DRY (001.1)** — every piece of knowledge has a single authoritative representation.
2. **Modular Architecture (001.2)** — each unit has one responsibility; dependencies flow one direction; no unit reaches into another's internals.
3. **Extensible by Construction (001.3)** — registries, polymorphism, and lookup tables are preferred over switch/if-else dispatch; adding a variant touches as few files as possible.
4. **Interface Boundaries (001.4)** — units expose contracts, not implementations; consumers depend on the contract, never on internal paths or unexported symbols.
5. **Centralized Configuration (001.5)** — settings and canonical constants live in one place per concern; downstream code reads from the canonical source, never from local copies.

### Alternatives Considered

| Alternative                   | Description                                  | Why Rejected                                                                 |
| ----------------------------- | -------------------------------------------- | --------------------------------------------------------------------------- |
| No formal standards           | Rely on tribal knowledge and ad-hoc review   | Does not scale; AI agents need explicit rules; human judgment is inconsistent |
| Single monolithic standards doc | One large file covering all standards       | Too large to maintain or reference; standards evolve at different rates       |
| Per-team standards            | Each team defines its own conventions         | Inconsistency at the boundaries where alignment matters most                  |
| Adopt an external style guide | Use a published guide as-is                   | Generic guides miss domain-specific structural concerns                       |

### Rationale

1. The five standards map directly onto the five forms of decay.
2. They are mutually reinforcing: DRY shrinks the surface Interface Boundaries must
   protect; Modular Architecture creates the structure Centralized Configuration
   relies on; Extensible by Construction reduces the files touched as the system grows.
3. Each is independently enforceable, avoiding all-or-nothing adoption.

---

## 3. Decision 2: Enforce Through Layered Automated Checks

### Decision

Standards are enforced by **layered automated checks**, not documentation alone. The
*kinds* of layer are universal; the concrete tooling is each project's responsibility:

| Layer                | Universal role                                          |
| -------------------- | ------------------------------------------------------- |
| Compiler / type check | Catch type- and boundary-level violations              |
| Linter               | Catch import, dispatch, and duplication patterns        |
| Structural CI guards | Catch naming and architectural violations tooling can express |
| Contract validation  | Enforce the interface boundary between units/services   |
| Code review          | Catch semantic violations tooling cannot express        |
| Single pre-merge gate | One command that runs all of the above                  |

### Enforcement

Each adopting project records its concrete realization of the layers above in its own
tech-stack ADRs (002.x) — e.g., which linter and rules, which CI guards, which build
gate command. A universal record names the layer and its role; it does not prescribe
the tool.

### Trade-offs Accepted

- Custom CI guards require maintenance as conventions evolve.
- Some standards (DRY, Extensible by Construction) cannot be fully automated and
  rely on review discipline.

---

## 4. Alternatives Considered

Covered per decision above. The overarching rejected alternative is **no enforcement**:
documentation-only standards decay because nothing prevents violations from merging.

---

## 5. Conclusion

The five standards form an interlocking system: DRY eliminates redundancy, Modular
Architecture defines the dependency graph, Extensible by Construction keeps the graph
open to growth, Interface Boundaries protect each node, and Centralized Configuration
prevents drift across nodes. Stated as principles and enforced by layered checks that
each project supplies for its stack, they scale with the codebase and apply equally to
human and AI contributors.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-30 | Initial creation |
