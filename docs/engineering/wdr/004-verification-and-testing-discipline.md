---
wdr: "004"
title: "Verification & Testing Discipline"
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
  - "005"
tags:
  - workflow
  - agentic
  - testing
---

# WDR 004: Verification & Testing Discipline

**Date:** 2026-05-31
**Status:** Modified
**Authors:** Robert Capps

---

## Executive Summary

The operating loop (WDR 003) says completion is established by running checks and
that the agent must not game a red signal. This record governs the checks
themselves, so that "the tests pass" actually means something: **tests fail
honestly when the behavior they cover breaks; a defect fix ships with a regression
test; required test depth scales with the change's risk; and the gate is
deterministic.** A proof shows that it can fail, on the commit it judges; tests leave no host
state; the checks that run are chosen from mapped inputs and written in a tracked file; and a
required proof that did not run is never a pass. Without these, a green signal is a number an agent learns to
satisfy rather than evidence the system works.

---

## Table of Contents

1. Problem Context
2. Decision 1: Tests Must Be Honest
3. Decision 2: A Defect Fix Ships With a Regression Test
4. Decision 3: Required Coverage Scales With Risk
5. Decision 4: The Gate Is Deterministic
6. Decision 5: A Proof Shows It Can Fail, on the Commit It Judges
7. Decision 6: Tests Leave No Host State and Run Within Limits
8. Decision 7: Checks Are Selected From Mapped Inputs and Written in a Tracked File
9. Decision 8: Not Proven Is Not Pass
10. Conclusion
11. Document History

---

## 1. Problem Context

### The Problem

An agent optimizing for a green signal will, unless constrained, find the cheapest
path to green — and the cheapest path is often to weaken the evidence rather than
strengthen the code: an assertion loosened to a tautology, a failing case marked
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

### Amendment (2026-11-25): deterministic proofs and a classified failure

A proof that can be reproduced is written as a deterministic check rather than left to a
reviewer's judgment; the review verdicts of WDR 005 stay the binding human-style gate and are not
replaced by checks. When a check fails in CI, the failure is classified first (a defect in the
change, a defect in the check, an infrastructure fault, or an unknown cause) before any retry. A
retry is allowed only for an infrastructure fault, within a cap the project sets; a check that
needs retries to pass is a flaky check under Decision 4.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** Should a red CI run be retried until it passes, retried a fixed number of times,
  or classified first? And should a reproducible proof be left to review?
- **Reason and scope:** an unclassified retry hides real failures and teaches that red means
  "try again"; a reproducible proof is cheaper and more reliable as a check. This governs every
  automated gate.
- **Strength:** default; the retry cap is each project's setting.

---

## 6. Decision 5: A Proof Shows It Can Fail, on the Commit It Judges

### Decision

A check that a gate relies on is shown to fail: it has a failure control, such as a seeded
defect, a mutation, a guard removed, or a fail-on-revert run, that it is observed to catch. A
"not found" result needs a known positive that the same check does find. The check runs on the
candidate: the exact commit being judged or, for CI on a pull request, the result of merging
that commit into its base, as the project's branch and merge record states. When the proof and the work it
proves need different trust or different runners, they run as separate jobs, so that the job under
test cannot change its own verdict.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** Is a check that passes evidence, or must it also be shown able to fail? The options
  were to trust a passing check, to require a failure control only for new checks of high-risk
  paths, or to require one for every check a gate relies on.
- **Reason and scope:** a check that has never failed may be unable to fail; it then reports
  safety that does not exist. This governs every check that a merge gate relies on.
- **Strength:** hard rule.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Trust a passing check | A green check is evidence enough | A check with a broken pattern or a wrong path passes forever |
| Failure controls for high-risk checks only | Show failure only where risk is high | Gate checks of every tier can be silently dead |

### Enforcement

Per project: each gate check has a committed failure control that runs with it; a "not found"
check names its known positive; proofs that need separate trust run in their own job.

---

## 7. Decision 6: Tests Leave No Host State and Run Within Limits

### Decision

A test creates nothing outside its own temporary space: no files in the user's home or the
repository, no global configuration, no services left running, no network writes. A suite that
can exhaust a host runs under process, memory and time limits. Where a test controls which
programs run (stubs, scheduled jobs, pipes), it names them by absolute path so a stub on the
search path cannot stand in for the real program.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** May a test rely on or change the host it runs on? The options were to allow it
  with cleanup, to allow it only in CI, or to forbid host state outright.
- **Reason and scope:** host state makes a result depend on what ran before, and agents run many
  suites on shared hosts. This governs all tests.
- **Strength:** hard rule; absolute command paths are a technique for controlled execution and
  a default.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Allow host state with cleanup | Tests may write anywhere if they clean up | A failed or killed run leaves state behind that changes the next result |
| Allow host state in CI only | Ephemeral runners make it harmless | Local runs are where agents test first; the same suite must be safe there |

### Enforcement

Per project: tests write only under a temporary folder they create; resource limits for suites
that need them; a review finding for a test that writes outside its folder.

---

## 8. Decision 7: Checks Are Selected From Mapped Inputs and Written in a Tracked File

### Decision

When a project runs only some checks for a change, it selects them from a tracked map of inputs
to checks. A rename, a shared path or a path the map does not know runs the checks broadly; a
release runs every check. The gate's commands live in a tracked file that agents read, such as the
project's check facts, not only in handoffs or chat.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** How should a change decide which checks to run, and where do the commands live?
  The options were running everything always, choosing by judgment, or selecting from a tracked
  map with broad fallbacks.
- **Reason and scope:** selection by judgment skips the check that mattered; a map is reviewable
  and fails safe toward running more. Commands in a tracked file stay the same for every agent
  and session. This governs every gate that selects checks.
- **Strength:** default.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Run everything always | No selection | Correct but slow enough that agents skip the local run |
| Select by judgment | The author decides what to run | The skipped check is the one the change broke |

### Enforcement

Per project: the map and the commands are tracked files; review checks that a change to a mapped
input runs its checks.

---

## 9. Decision 8: Not Proven Is Not Pass

### Decision

A gate has three outcomes: **pass**, **fail**, and **incomplete**. A required proof that did not
run — missing input, a tool not installed, a base that could not be read — makes the gate
incomplete, with its own non-zero outcome; it is never reported as a pass. An intentional
out-of-scope skip, with its reason recorded, is a fourth, separate result and does not make the
gate incomplete.

- **Decided by:** Robert Capps
- **Date:** 2026-11-25
- **Context:** What does a gate report when a required check could not run? The options were to
  report pass with a warning, fail, or a distinct incomplete outcome.
- **Reason and scope:** a check that did not run proves nothing; a pass with a warning is read as
  a pass. A distinct outcome keeps "could not check" apart from "found a defect". This governs
  every gate and every report of one.
- **Strength:** hard rule.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Pass with a warning | Skip the missing check and pass | Warnings are not read; an unproven change merges |
| Report it as a failure | Treat "did not run" as "found a defect" | Hides the real cause and sends the author to fix code that may be fine |

### Enforcement

Per project: gate scripts exit with a distinct status for incomplete; reports list each check as
passed, failed, incomplete or skipped with its reason.

---

## 10. Conclusion

Verification discipline makes a green signal trustworthy: tests fail honestly,
fixes carry regression proof, coverage depth tracks risk, and the gate's verdict is
deterministic. Together with the operating loop's "verify by execution" (WDR 003),
this is what lets the independent review (WDR 005) and CI rely on a passing gate as
real evidence rather than a number the agent learned to satisfy. The concrete test
frameworks, coverage tools, risk-tier mapping, and flakiness tracking are each
adopting project's enforcement. Each gate check shows it can fail, runs on the commit it judges and
leaves no host state; the checks are chosen from a tracked map; and a proof that did not run is
reported as incomplete, never as a pass.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
| 2026-11-25 | Decision 4 amendment: deterministic proofs and classified failures. Decisions 5–8: failure controls on the candidate tree, no host state, mapped selection with tracked commands, and the incomplete outcome |
