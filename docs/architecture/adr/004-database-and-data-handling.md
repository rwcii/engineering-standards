---
adr: "004"
title: "Database & Data Handling"
status: draft
created: "2026-05-30"
updated: "2026-05-30"
parent_adr: ""
authors:
  - "Robert Capps"
reviewers: []
supersedes: ""
superseded_by: ""
related:
  - "002.3"
tags:
  - architecture
  - database
  - data-modeling
---

# ADR 004: Database & Data Handling

**Date:** 2026-05-30
**Status:** Draft
**Authors:** Robert Capps

> **Template.** Record the datastore technology and the project's data-handling policy
> at a high level; put specifics in point versions (004.1, 004.2, …). Then set
> `status: accepted`. The guidance below states data-handling principles that tend to
> generalize — keep what applies, make it concrete, drop what doesn't.

---

## Executive Summary

[The datastore technology, the migration strategy, and the project's stance on
constrained values and boundary normalization. Specifics live in 004.x.]

---

## Table of Contents

1. Problem Context
2. Decision: Datastore Technology
3. Decision: Migration Strategy
4. Decision: Constrained Values & Boundary Normalization
5. Conclusion
6. Document History

---

## 1. Problem Context

### The Problem

[The data the system manages; integrity, evolution, and consistency requirements.]

### Requirements

1. [e.g., constrained fields cannot hold invalid values, ever]
2. [e.g., schema changes are reproducible across environments]

### Scope

Datastore technology and cross-cutting data-handling policy. Specific schema or
ingestion decisions go in point versions (004.x) or project ADRs (007+). How backend
code reaches the datastore is 002.3.

---

## 2. Decision: Datastore Technology

### Decision

[The datastore(s) and driver, and why.]

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| [Name]      | [What]      | [Why]        |

---

## 3. Decision: Migration Strategy

### Decision

[How schema changes are authored, ordered, and applied across environments.
Recommended principle: migrations are **sequential and forward-only**, version
controlled, and applied the same way everywhere. Record how migrations run in each
environment, including production.]

---

## 4. Decision: Constrained Values & Boundary Normalization

### Decision

Two data-handling principles that generalize well — adopt and make concrete, or
replace with the project's own:

1. **Constrained values are enforced at the data layer, not only in clients.** Values
   from a fixed set are constrained where the data lives (e.g., database enums,
   constraints) and the valid set is served to clients from that source of truth — never
   enforced by client code alone. (Consistent with DRY, 001.1, and Centralized
   Configuration, 001.5.)
2. **Normalize at the boundary; store canonical.** Inputs are normalized to a canonical
   form as they enter the system (e.g., phone numbers, identifiers, codes) so every
   downstream consumer reads one consistent representation.

### Enforcement

[Schema-level constraints/enums; a single endpoint or module that serves the valid
constrained-value sets; normalization at every ingestion boundary; tests for invalid and
unnormalized inputs.]

---

## 5. Conclusion

[How the datastore and data-handling policy serve the project's integrity requirements.]

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-30 | Initial creation |
