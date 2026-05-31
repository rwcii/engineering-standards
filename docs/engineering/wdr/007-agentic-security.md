---
wdr: "007"
title: "Agentic Security"
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
  - "006"
tags:
  - workflow
  - agentic
  - security
---

# WDR 007: Agentic Security

**Date:** 2026-05-31
**Status:** Accepted
**Authors:** Robert Capps

---

## Executive Summary

Agent-driven development opens attack surfaces that do not exist for human
engineers: content the agent reads can carry instructions, code the agent writes was
never reviewed before it ran, and dependencies the agent reaches for may not exist.
This record establishes three controls: **untrusted content is never instructions,
and the lethal combination of private data + untrusted content + an exfiltration
channel is never co-located without a gate**; the agent executes in a **hermetic,
least-privilege sandbox** with enumerated tools and deny-by-default egress; and
**no agent-introduced dependency enters the tree unproven, while secrets never flow
into the agent's context or out into generated artifacts.** These are the
agent-specific complement to the project's general security posture (ADR 005).

---

## Table of Contents

1. Problem Context
2. Decision 1: Untrusted Content Is Never Instructions
3. Decision 2: The Agent Executes in a Hermetic, Least-Privilege Sandbox
4. Decision 3: Dependencies Are Proven and Secrets Never Cross the Boundary
5. Conclusion
6. Document History

---

## 1. Problem Context

### The Problem

An agent ingests text from many sources during a task — issue descriptions, web
pages, tool and MCP-server output, dependency READMEs, test fixtures — and a language
model does not natively distinguish *data to process* from *instructions to follow*.
Attacker-controlled text in any of those sources can hijack the agent. The danger
peaks when three capabilities meet in one context: access to **private data**,
exposure to **untrusted content**, and a channel to **act or exfiltrate** (network,
commit, tool call). Any one alone is survivable; all three together is the lethal
combination.

Two more surfaces are unique to agent authorship. The agent runs code that was never
human-reviewed before execution, so the environment it runs in is itself part of the
threat model. And the agent reaches for dependencies by name — but a meaningful
fraction of package names that models suggest **do not exist**, which attackers
pre-register and weaponize (slopsquatting), while secrets can be pulled into the
agent's context or emitted into generated code, tests, and fixtures.

### Requirements

1. Content ingested at work-time cannot redirect the agent's behavior.
2. What the agent's execution can reach is bounded and enumerated, not ambient.
3. Dependencies are verified before adoption, and secrets never enter the agent's
   context or its output.

### Scope

Agent-specific security. The project's general posture — classic threat model, data
protection, transport, headers — is ADR 005; authentication is ADR 006. The autonomy
tiers and resource ceilings that bound *what the agent may do* are WDR 006; this
record bounds *what it may reach and trust*.

---

## 2. Decision 1: Untrusted Content Is Never Instructions

### Decision

Content the agent ingests at work-time — issues, web pages, tool/MCP output,
dependency docs, fixtures, any third-party text — is treated as **data, never as
instructions**. A single agent context must not simultaneously hold access to
private data, exposure to untrusted content, and an egress/action channel **without a
gate** between ingestion and action. Where the combination is unavoidable, a human
or a deterministic check sits between reading untrusted content and acting on it.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Trust ingested content | Let the agent act on instructions found in fetched text | Prompt injection: attacker-controlled text becomes attacker-controlled actions |
| Filter prompts for "bad" instructions | Scan ingested text for injection patterns | Injection is open-ended and easily obfuscated; a denylist cannot enumerate it. Isolating the *capability combination* is robust where content filtering is not |

### Rationale

1. The vulnerability is structural — models conflate data and instructions — so the
   control must be structural, not a content filter.
2. Breaking up the lethal combination removes the *capability* to be exploited, which
   holds regardless of how clever the injection is.
3. This threat simply does not exist in human-only workflows; it must be named
   explicitly or it is missed.

### Enforcement

Per project: classify tool/MCP outputs and fetched content as untrusted; keep
private-data access, untrusted content, and egress from co-existing ungated in one
context; a gate (human or deterministic) before acting on untrusted input.

---

## 3. Decision 2: The Agent Executes in a Hermetic, Least-Privilege Sandbox

### Decision

The agent runs in a **hermetic, least-privilege sandbox**: the tools and MCP servers
it may call are **enumerated and allowlisted** (start empty, expand deliberately);
filesystem writes are **scoped to the repository/workspace**; network egress is
**deny-by-default with an explicit allowlist**; and **no ambient production
credentials** are present. The sandbox is simultaneously a security control (it
bounds the blast radius of injected or hallucinated code) and a reproducibility
control (no live external dependencies means deterministic runs).

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Run on the developer's host | The agent shares the human's full environment and credentials | Unreviewed code runs with ambient production access; blast radius is the whole machine |
| Broad tool access, block known-bad | Enable tools freely, deny specific dangers | Deny-lists miss the unanticipated; an allowlist that starts empty fails safe |
| Open egress | Allow outbound network by default | Open egress is the exfiltration half of the lethal combination and breaks run determinism |

### Rationale

1. Unreviewed code must run somewhere bounded; the sandbox is that boundary.
2. Deny-by-default (tools and egress) fails safe — the unanticipated capability is
   absent, not present by oversight.
3. Hermeticity makes verification (WDR 003/004) both safe and reproducible at once.

### Enforcement

Per project: an enumerated tool/MCP allowlist; repo-scoped filesystem writes;
deny-by-default egress with an allowlist; scoped, time-limited credentials rather
than raw keys; per-tool authorization handled in the deployment layer.

---

## 4. Decision 3: Dependencies Are Proven and Secrets Never Cross the Boundary

### Decision

**No agent-introduced dependency enters the tree unproven.** A package the agent adds
must be shown to **exist and be the intended one** (defending against hallucinated and
slopsquatted names), pinned to an exact version, integrity-checked, and
provenance/vulnerability-vetted; this covers pasted snippets and `curl | sh`-style
install steps as well as package-manifest entries. And **secrets never cross the
agent boundary** — they do not flow *into* the agent's context, transcripts, or a
third-party model, nor *out* into generated code, tests, or fixtures — enforced by a
scan before commit/egress.

### Alternatives Considered

| Alternative | Description | Why Rejected |
| ----------- | ----------- | ------------ |
| Trust suggested dependencies | Install packages the agent names | A meaningful fraction of model-suggested package names do not exist; attackers pre-register them — a live, exploited attack path |
| Floating versions | Accept dependencies on a range or "latest" | Re-resolution can pull a compromised or drifted version after vetting; pinning + integrity is what holds |
| Secrets as a runtime-only concern | Guard secrets only in the running system | Ignores the new ingress (into the agent's context/model) and egress (into generated artifacts) that agent authorship creates |

### Rationale

1. Verifying existence-and-identity before adoption closes the slopsquatting path at
   the moment of introduction.
2. Pin-plus-integrity makes a vetted dependency stay the thing that was vetted.
3. Treating secrets as crossing a *boundary* (in and out of the agent) covers the
   exposure ADR 005's runtime stance does not.

### Enforcement

Per project: dependency existence/identity verification, exact pinning, integrity
and vulnerability checks in the gate; a secrets scan before commit and before any
egress; pairs with ADR 005 (secrets management) and the pinned-toolchain record.

---

## 5. Conclusion

Agentic security closes the surfaces human-only workflows never had: untrusted
content is data and never instructions (and the lethal data+content+egress
combination is gated), execution is hermetic and least-privilege, dependencies are
proven before adoption, and secrets never cross the agent boundary. These compose
with the autonomy guardrails (WDR 006) — which bound what the agent may *do* — and
cross-link the project's general security record (ADR 005). The concrete sandbox,
allowlists, scanners, and verification tooling are each adopting project's
enforcement.

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-31 | Initial creation |
