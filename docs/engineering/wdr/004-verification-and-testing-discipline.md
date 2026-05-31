---
wdr: "004"
title: "Verification & Testing Discipline"
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
  - "003"
  - "005"
tags:
  - workflow
  - agentic
  - testing
---

# WDR 004: Verification & Testing Discipline

**Date:** 2026-05-31
**Status:** Accepted
**Authors:** Robert Capps

---

## Executive Summary

The operating loop (WDR 003) says completion is established by running checks and
that the agent must not game a red signal. This record governs the checks
themselves, so that "the tests pass" actually means something: **tests fail
honestly when the behavior they cover breaks; a defect fix ships with a regression
test; required test depth scales with the change's risk; and the gate is
deterministic.** Without these, a green signal is a number an agent learns to
satisfy rather than evidence the system works.

---

## Table of Contents

1. Problem Context
2. Decision 1: Tests Must Be Honest
3. Decision 2: A Defect Fix Ships With a Regression Test
4. Decision 3: Required Coverage Scales With Risk
5. Decision 4: The Gate Is Deterministic
6. Conclusion
7. Document History

---

## 1. Problem Context

### The Problem

An agent optimizing for a green signal will, unless constrained, find the cheapest
path to green — and the cheapest path is often to weaken the evidence rather than
the strengthen the code: an assertion loosened to a tautology, a failing case marked
skipped, an over-mocked test that exercises nothing, a fix with no test proving it.
A flaky gate makes this worse: when red sometimes means "try again," the agent (and
the humans watching) learn that red is noise, not a stop. And a uniform coverage
demand is both too much (ceremony on a docs change) and too little (a green suite is
no comfort on an auth path with no adversarial tests).

A human is held back by professional norms and a reviewer looking over their
shoulder; an autonomous agent has neither in its inner loop. The discipline must be
written down and checkable.

### Requirements

1. A passing test suite is genuine evidence the covered behavior works.
2. Fixed defects do not silently return.
3. Test depth is proportional to the blast radius of the change.
4. The gate's verdict is reproducible, so "passing" is a fact, not a coin flip.

### Scope

Covers test integrity, regression capture, coverage obligation, and gate
determinism. The agent's behavioral reaction to a red signal is WDR 003; the
severity/blocking contract of the merge gate is WDR 005. This record is about how
*fixes and changes are validated*, not a record *of* any particular fix.

---

## 2. Decision 1: Tests Must Be Honest

### Decision

A test genuinely fails when the behavior it covers breaks. Making a check pass by
disabling it — deleting or skipping it, marking it expected-to-fail, loosening an
assertion to triviality, swallowing the error, or editing the test to match buggy
output — is prohibited as a way to reach green. Tests assert observable behavior, not
their own mocks; an assertion that cannot fail is not a test.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Green is green | Accept a passing suite however it was achieved | Rewards neutering the check over fixing the code; a tautological or skipped test reports safety that does not exist |
| Mock liberally to isolate | Replace collaborators with mocks wherever convenient | Over-mocking produces tests that pass when the real system is broken; the test exercises the mock, not the behavior |

### Rationale

1. A test's only value is that it *can* fail; a check that cannot fail is decoration.
2. Honest tests are the precondition that makes WDR 003's "verify by execution" real.
3. Disabled or weakened checks are a discrete, reviewable event a gate can detect.

### Enforcement

Per project: review flags newly skipped/weakened tests and tautological assertions
in the diff; mutation or coverage signals where the stack supports them; data
boundaries tested against real dependencies rather than mocks.

---

## 3. Decision 2: A Defect Fix Ships With a Regression Test

### Decision

A fix for a defect ships with a test that was **observed failing before the fix and
passing after** — turning "I fixed it" into demonstrated evidence the defect existed
and is gone. The test is committed with the fix.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Fix now, test later | Land the fix and add coverage in a follow-up | The follow-up rarely comes; the defect can silently return with nothing to catch it |
| Trust the fix | Accept the fix because the logic now looks right | Without a red-then-green test, there is no evidence the fix addresses the actual defect rather than a guess at it |

### Rationale

1. A test seen failing first proves it actually exercises the defect.
2. The regression test is the durable guard that the defect does not recur.
3. It is binary and reviewer-checkable on a fix-shaped change.

### Enforcement

Per project: review confirms a fix includes a regression test demonstrated to fail
without the fix; the test lands in the same change.

---

## 4. Decision 3: Required Coverage Scales With Risk

### Decision

The test depth a change must carry is tied to its **risk tier**. For
security, authentication, authorization, data-integrity, money-handling, or
irreversible paths, a missing test layer (including adversarial cases) is
**blocking**. For low-risk changes — internal refactors or documentation with the
existing suite staying green — the existing coverage suffices. The obligation is
proportionate, not uniform.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Uniform coverage target | Demand the same coverage of every change | Ceremony on trivial changes, false comfort on dangerous ones; ignores blast radius |
| Coverage at author's discretion | Let each change decide its own depth | High-risk paths get under-tested exactly when it matters; no anchor for the gate |

### Rationale

1. Proportional depth honors ADR 001's "overhead proportional to benefit."
2. It puts the required rigor where the blast radius is, instead of spreading it
   thin and uniform.
3. It makes the gate's coverage expectation concrete enough to check per change.

### Enforcement

Per project: a risk-tier mapping (which areas demand which layers, including
adversarial categories); review treats a missing layer on a high-risk change as
blocking; ties to the data and security records (ADR 004/005).

---

## 5. Decision 4: The Gate Is Deterministic

### Decision

For an automated gate to legitimately block, its verdict must be reproducible. Flaky
checks are **defects, not noise**; retry-until-green is not a pass strategy; an
unreliable check is **quarantined out of the blocking gate** and tracked until
fixed. Checks are deterministic by construction — frozen clock, seeded randomness,
order-independence, no reliance on live external services, governed test doubles at
the boundary.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Tolerate flakiness, re-run | Re-run the gate until it passes | Teaches the agent and the team that red means "try again," not "stop" — corrosive in an inner loop |
| Keep flaky checks blocking | Leave unreliable checks in the gate | They erode trust in every verdict; people start ignoring red, which defeats the gate |

### Rationale

1. A nondeterministic gate cannot legitimately block — its red is not evidence.
2. Quarantining preserves the signal of the reliable gate while the flaky check is
   repaired.
3. Determinism is what lets "the gate passed" be a durable fact rather than a moment.

### Enforcement

Per project: a flakiness policy (quarantine + track, do not retry-to-green);
deterministic test construction (frozen time, seeded randomness, no live external
calls); pairs with ADR 003 (environment parity) and ADR 004 for seed/fixture data.

---

## 6. Conclusion

Verification discipline makes a green signal trustworthy: tests fail honestly,
fixes carry regression proof, coverage depth tracks risk, and the gate's verdict is
deterministic. Together with the operating loop's "verify by execution" (WDR 003),
this is what lets the independent review (WDR 005) and CI rely on a passing gate as
real evidence rather than a number the agent learned to satisfy. The concrete test
frameworks, coverage tools, risk-tier mapping, and flakiness tracking are each
adopting project's enforcement.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
