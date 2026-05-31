---
adr: "005"
title: "Security"
status: draft
created: "2026-05-30"
updated: "2026-05-31"
parent_adr: ""
authors:
  - "Robert Capps"
reviewers: []
supersedes: ""
superseded_by: ""
related:
  - "006"
tags:
  - security
---

# ADR 005: Security

**Date:** 2026-05-30
**Status:** Draft
**Authors:** Robert Capps

> **Stub.** Placeholder for the project's security model. Fill in when the decisions are
> made; until then this record marks security as a tracked, deliberate concern rather
> than an oversight. Authentication is recorded separately in ADR 006.

---

## Executive Summary

[The project's security posture: threat model, data-protection requirements, secrets
handling, input validation, and content/output safety. To be completed when these
decisions are made.]

---

## Table of Contents

1. Problem Context
2. Decision(s) — *to be determined*
3. Conclusion
4. Document History

---

## 1. Problem Context

### The Problem

[What must be protected, from whom, and the consequences of failure. Note the
deployment exposure — internal-only vs. public — and how that scopes the threat model.]

### Requirements

[Numbered list once known — e.g., secrets never in source control; all external input
validated; sensitive data encrypted in transit and at rest.]

### Scope

Security posture broadly. Authentication is ADR 006. Authorization, if separate, gets
its own record. Data-handling integrity is ADR 004. Agent-specific security —
prompt-injection isolation, the hermetic execution sandbox, tool governance,
supply-chain/slopsquatting defenses, and secrets non-exposure — is **WDR 007**; this
record covers the classic security posture that those agent controls bind to.

---

## 2. Decision(s) — to be determined

> Candidate areas to decide and record here:
>
> - **Secrets management** — where secrets live, how they're injected, rotation
> - **Input validation** — where and how all external input is validated
> - **Data protection** — encryption in transit/at rest, PII handling, retention
> - **Output/content safety** — sanitization of stored content rendered to users
> - **Transport & headers** — TLS, security headers, CORS
> - **Dependency & supply chain** — vulnerability scanning, pinning
> - **AI-generation threats** — prompt injection, hallucinated/slopsquatted
>   dependencies, secrets pulled into generated code, insecure-by-default generation.
>   The agent-specific controls are recorded in WDR 007; record here how they bind to
>   this project's security posture.
>
> Each becomes a Decision section (Decision / Alternatives / Rationale / Enforcement)
> once settled, following `ADR_PROCESS.md`.

---

## 3. Conclusion

[To be written once decisions exist.]

---

## Document History

| Date       | Change           |
| ---------- | ---------------- |
| 2026-05-30 | Initial creation (stub) |
| 2026-05-31 | Added AI-generation-threats candidate area and WDR 007 cross-reference |
