---
adr: "003"
title: "Reproducible Environments & Observability"
status: accepted
created: "2026-05-31"
updated: "2026-05-31"
parent_adr: ""
authors:
  - "Robert Capps"
reviewers: []
supersedes: ""
superseded_by: ""
related:
  - "001.5"
tags:
  - architecture
  - config
  - deployment
  - observability
  - enforcement
---

# ADR 003: Reproducible Environments & Observability

**Date:** 2026-05-31
**Status:** Accepted
**Authors:** Robert Capps

---

## Executive Summary

ADR 001 governs how code is *structured*; this record governs the environment that
code runs in and how its behavior is *observed*. Both are universal, both survive a
product pivot, and both became load-bearing once agents started doing the work: an
agent's "it passes" means nothing unless it ran in the same environment CI will use,
and an agent (or a human) cannot verify behavior it cannot observe.

This record establishes three operational standards: a **single source-of-truth
environment manifest** that agent, CI, and developer all consume; a **deterministic,
pinned toolchain and dependency set** so a clean checkout is reproducible; and
**runtime observability** — structured, correlatable signals — so the running system's
behavior is inspectable. The concrete manifest format, pinning mechanism, and
telemetry stack are each adopting project's enforcement.

---

## Table of Contents

1. Problem Context
2. Decision 1: One Source-of-Truth Environment Manifest
3. Decision 2: A Deterministic, Pinned Toolchain and Dependencies
4. Decision 3: Systems Emit Structured, Correlatable Observability Signals
5. Conclusion
6. Document History

---

## 1. Problem Context

### The Problem

Three operational gaps undermine everything built on top of them, and each one is
sharper in an agent-driven workflow:

- **Environment drift.** When the agent's runtime, the CI runtime, and the
  developer's machine differ, "passed for the agent, failed in CI" becomes routine —
  and the agent's self-verification (WDR 003) is unfalsifiable, because its green
  check was never run where the truth is decided.
- **Non-determinism.** Floating dependency versions and an unpinned toolchain mean a
  clean checkout is not the same twice; a build that worked yesterday breaks today
  for reasons unrelated to any change, and dependency drift quietly reopens
  supply-chain exposure.
- **Opacity.** A system that emits no structured signal cannot be verified by
  observed evidence; a failure in production is a guess, and an agent asked to
  confirm behavior has nothing to observe.

These are not project-specific quirks; they are universal preconditions for
verification, reproducibility, and operability.

### Requirements

1. The environment is defined once and consumed identically by agent, CI, and
   developer.
2. A clean checkout reproduces the same toolchain and dependencies every time.
3. The running system's behavior is inspectable through structured, correlatable
   signals.

### Scope

Covers environment parity, toolchain/dependency determinism, and runtime
observability as universal principles. Centralized configuration of *values* is ADR
001.5; the agent's obligation to verify by execution against this environment is WDR
003; gate determinism that depends on it is WDR 004.

---

## 2. Decision 1: One Source-of-Truth Environment Manifest

### Decision

The runtime versions, tool versions, and service topology an environment requires are
declared in a **single, version-controlled manifest** that the agent, CI, and the
developer environment all consume. There is no second, hand-maintained description of
the environment that can drift from it; the manifest is the source of truth.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Per-environment ad-hoc setup | Each of agent/CI/dev sets itself up its own way | Drift is guaranteed; "works here, not there" is unsolvable because there is no shared definition |
| Documented but unenforced setup | A README describes the environment; humans follow it | Prose drifts from reality; an agent cannot reliably consume it; nothing fails when it is wrong |

### Rationale

1. One manifest consumed by all three is the only way agent self-verification means
   the same thing as CI.
2. It is ADR 001.5 ("one canonical source per concern") applied to the environment
   layer.
3. A machine-consumable manifest is reproducible setup, not a ritual a human or agent
   performs differently each time.

### Enforcement

Per project: a single environment manifest (the concrete form is the project's
choice) consumed by agent, CI, and dev; CI that provisions from it; drift between the
manifest and the actual environment treated as a defect.

---

## 3. Decision 2: A Deterministic, Pinned Toolchain and Dependencies

### Decision

The runtime, package manager, formatters/linters/codegen, and all dependencies are
**pinned to exact, committed versions** (lockfiles committed), so a clean checkout
resolves to the same toolchain and dependency graph every time. Reproducibility is by
construction, not by luck of resolution timing.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Version ranges | Depend on ranges and resolve at install time | Re-resolution drifts the tree; "it built yesterday" breaks for reasons unrelated to any change |
| Track latest | Always pull the newest versions | Maximizes drift and surprise; reopens supply-chain exposure between vettings |

### Rationale

1. Exact pinning makes "passed for the agent, failed in CI" impossible by
   construction — both resolve the same tree.
2. Committed lockfiles make dependency changes a reviewable event, not an invisible
   resolution.
3. Determinism is the precondition for a gate whose verdict is reproducible (WDR 004)
   and blunts the dependency drift that supply-chain attacks exploit (WDR 007).

### Enforcement

Per project: pinned runtime/toolchain and committed lockfiles; a check that a clean
install reproduces the locked graph; dependency bumps as explicit, reviewed changes.

---

## 4. Decision 3: Systems Emit Structured, Correlatable Observability Signals

### Decision

A system emits **structured, correlatable signals** — logs, metrics, and traces with
stable correlation identifiers and a consistent schema — so its runtime behavior is
inspectable rather than inferred. Observability is a property the system is built to
have, not an afterthought bolted on when something breaks.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Ad-hoc logging | Unstructured prints added where convenient | Not correlatable or queryable; useless for tracing a request or verifying behavior |
| Add observability when needed | Instrument only after an incident demands it | The signal is absent exactly when the incident happens; behavior cannot be reconstructed after the fact |

### Rationale

1. Verification by observed evidence (WDR 003) requires there to be something to
   observe; structured signals are that something.
2. Correlatable signals make a system's behavior reconstructable in production rather
   than a guess.
3. A consistent schema is what lets both humans and agents query behavior instead of
   grepping prose.

### Enforcement

Per project: a structured logging/metrics/tracing stack with stable correlation IDs
and a consistent schema; instrumentation treated as part of the change, not a
follow-up; the concrete telemetry tools are the project's choice.

---

## 5. Conclusion

Reproducible environments and observability are the operational counterpart to ADR
001's structural standards: one manifest the agent, CI, and developer all share; a
pinned toolchain so a clean checkout is the same every time; and structured signals so
runtime behavior can be observed rather than guessed. Together they are what make
agent self-verification meaningful, gate verdicts reproducible, and production
behavior inspectable. The concrete manifest, pinning mechanism, and telemetry stack
are each adopting project's enforcement.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
