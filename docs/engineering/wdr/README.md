# Workflow Decision Records (WDRs)

WDRs document **how the work is done** — the engineering workflow, the agent
operating loop, the review and enforcement gates, and the decision-record system
itself. They are the third record type alongside ADRs (how the system is *built*)
and PDRs (how the product *behaves*). For process rules, the classification test,
and the template, see [WDR_PROCESS.md](WDR_PROCESS.md).

WDRs reuse the ADR template, lifecycle, and review path; only the scope differs. A
decision that survives **both** a complete rewrite and a complete product pivot —
because it governs how the team and its agents work — is a WDR.

## Baseline WDRs

| Number | Title                                                              | Status   |
| ------ | ------------------------------------------------------------------ | -------- |
| 001    | [Decision-Record Taxonomy & the WDR Series](001-decision-record-taxonomy.md) | Accepted |
| 002    | [Record System as Infrastructure](002-record-system-as-infrastructure.md)    | Accepted |
| 003    | [Agent Operating Loop](003-agent-operating-loop.md)                          | Accepted |
| 004    | [Verification & Testing Discipline](004-verification-and-testing-discipline.md) | Accepted |
| 005    | [Independent Review & Control-Plane Protection](005-independent-review-and-control-plane.md) | Accepted |
| 006    | [Agent Autonomy & Guardrails](006-agent-autonomy-and-guardrails.md)          | Accepted |
| 007    | [Agentic Security](007-agentic-security.md)                                  | Accepted |
| 008    | [Context & Memory Engineering](008-context-and-memory-engineering.md)        | Accepted |
| 009    | [AI Provenance & Accountability](009-ai-provenance-and-accountability.md)    | Accepted |

The baseline set (001–009) is complete and universal. Project-specific WDRs begin at
**010**.

## Project-specific (this repository)

| Number | Title | Status |
| ------ | ----- | ------ |
| 010    | [Branch & Merge Flow](010-branch-and-merge-flow.md) | Accepted |
| 011    | [Contribution & Attestation Policy](011-contribution-and-attestation.md) | Accepted |
