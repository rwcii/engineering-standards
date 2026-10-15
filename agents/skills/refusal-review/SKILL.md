---
name: refusal-review
description: Independent preflight that traces every refusal, prohibition, approval or stop step, cap and exclusion a branch adds or changes to a source covering its case (WDR 005, Decision 4). Use before push/PR beside standards-review, or when asked to check a change for unsourced refusal language, gates or limits.
---

# Refusal Review — Preflight Check

Review every constraint that the changes on the current branch add or change — refusals,
prohibitions, approval and stop steps, caps, exclusions and scope limits — and confirm
that each one has a source that covers its case. This review is a preflight gate before
push/PR and runs beside `standards-review`, with its own verdict (WDR 005, Decision 4).

**This review MUST be performed by a separate agent** with no prior context from the
working conversation. Start it in a fresh context, such as a subagent or a new agent session, so
it gives an independent assessment.
The agent must follow every instruction below exactly.

> **Adopting this skill:** this is a stack-agnostic skeleton. Set your base branch
> default below and name who records decisions in your project (the accountable human or
> authorizing principal of WDR 009) and where (records, issue tracker, decision board).
> The protocol and output format are universal.

## Arguments

- `$ARGUMENTS` — optional: base branch override (defaults to `develop`)

## Agent Instructions

The review agent receives the full instructions below. Do NOT summarize or abbreviate them.

---

### Why this gate exists

Agents write constraints that nobody decided: a plan's scope note becomes "never do X",
a skill gains a new "ask before Y", a test asserts a refusal that no requirement asked
for. Later agents read that text as a rule, refuse work and ask for approval the task
already gave. A general review checks whether the change is correct; this review checks
whether each limit the change adds was actually decided, and for which case.

### MANDATORY REVIEW PROTOCOL

1. **READ THE ACTUAL DIFF.** Read every changed file in full. Judge what each sentence,
   test and condition does, not its wording. A keyword search can find candidates; it is
   not the review.
2. **ADDED OR CHANGED ONLY.** Constraints the diff does not add or change are out of
   scope. Do not audit the whole repository.
3. **FIND THE SOURCE, DO NOT ASSUME IT.** A citation proves nothing until you have read
   the cited record or requirement and confirmed that its scope covers this case.
4. **NO SPECULATION.** A hypothetical concern is not a source and not a finding.

---

### Phase 0: Establish Scope

```bash
BASE_BRANCH="${ARGUMENTS:-develop}"
git diff $(git merge-base HEAD $BASE_BRANCH)...HEAD --stat
git diff $(git merge-base HEAD $BASE_BRANCH)...HEAD
```

Read every changed file completely, and the ADR, PDR and WDR indexes.

---

### Phase 1: List the Constraints

List every added or changed constraint, in any file — records, plans, agent
instructions, skills, docs, tests and code:

- prohibitions, refusals and exclusions, however phrased — including positively phrased
  requirements that leave something out ("only X", "X is the sole path");
- approval, stop, wait and permission steps, and new reasons to ask a human;
- caps, limits, scope boundaries, and code conditions that refuse or skip work;
- tests that assert a refusal or a limit.

---

### Phase 2: Find Each Source

Each constraint needs a source that covers its case:

- an accepted decision record (ADR, PDR or WDR) whose scope includes the case;
- the requirement of the issue or plan that the change delivers;
- the accountable human's own words (WDR 009), quoted with date and the question they
  answered;
- a verified platform, API, storage or protocol contract, or a reproduced correctness or
  security boundary.

Needs no further source: routine input validation and a demonstrated capability limit.
Neither may be turned into a new approval step.

Is a finding:

- **unsourced** — no source covers the constraint;
- **extrapolated** — the source covers a narrower case than the constraint claims;
- **proposal stated as rule** — a draft or proposed choice written as decided;
- **new approval step without authority** — a request for permission that the task or
  an accepted record already gives.

---

### Phase 3: Self-Audit

- For each "pass", did you read the source, or only see that one was cited?
- Did you include positively phrased limits, tests and code conditions, not only prose
  with "never" or "must not"?
- Did you report any constraint the diff did not add or change? Remove it.

---

## Severity

Classify findings on the WDR 005, Decision 2 scale. This gate uses two of its levels:

- **high** (blocks merge): any unsourced constraint, extrapolated constraint, proposal
  stated as rule, or new approval step without authority that changes behavior — what an
  agent, user or system does, refuses, skips or waits for.
- **medium** (tracked, does not block): wording that overstates a sourced constraint, or
  an unsourced constraint, that does not change behavior.

A high finding blocks until the constraint is removed, narrowed, cited or recorded, or the
finding is waived under WDR 005, Decision 2.

---

## Output Format

```
## Scope
- Branch: [branch name]
- Base: [base branch]
- Files changed: N

## Constraints
| # | File | Constraint (quoted) | Kind | Source | Covers this case? |
|---|------|---------------------|------|--------|-------------------|
| 1 | ... | ... | refusal/approval/cap/exclusion/test/code | record, requirement, quote or contract | yes/no/narrower |

## Findings
| # | Severity | File | Finding | Recommended Fix |
|---|----------|------|---------|-----------------|
| 1 | high/medium | ... | unsourced/extrapolated/proposal stated as rule/new approval step | remove, narrow, cite, or record the decision |

## Summary
- Constraints reviewed: N
- Findings: N (X high, Y medium)
- Recommendation: APPROVE / REQUEST CHANGES
```

**Do NOT approve with any high finding.** An empty constraints table is a valid result
when the diff adds no constraint.
