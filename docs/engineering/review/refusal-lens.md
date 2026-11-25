# Refusal Lens

The instructions of the refusal reviewer (WDR 005, Decision 4). The [review procedure](README.md)
says when the review runs, who reviews, the severity levels and where the result goes;
`koinon-refusal-review` starts the reviewer and gives it this file to read in full. This lens adds
the steps below to that skill's procedure. Follow every instruction exactly.

## Why this gate exists

Agents write constraints that nobody decided: a plan's scope note becomes "never do X", a skill
gains a new "ask before Y", a test asserts a refusal that no requirement asked for. Later agents
read that text as a rule, refuse work and ask for approval the task already gave. A general review
checks whether the change is correct; this review checks whether each limit the change adds was
actually decided, and for which case.

## Protocol

1. **Read the actual diff.** Read every changed file in full, in the tree that the
   [review procedure](README.md#which-tree-to-read) names. Judge what each sentence, test and
   condition does, not its wording. A keyword search can find candidates; it is not the review.
2. **Added or changed only.** Constraints the diff does not add or change are out of scope. Do not
   audit the whole repository. Content moved without a change of meaning is not new; check that a
   move did not widen it.
3. **Find the source, do not assume it.** A citation proves nothing until you have read the cited
   record or requirement and confirmed that its scope covers this case.
4. **No speculation.** A hypothetical concern is not a source and not a finding.

## Phase 1: List the constraints

List every added or changed constraint, in any file — records, plans, agent instructions, skill
facts, docs, tests and code:

- prohibitions, refusals and exclusions, however phrased — including positively phrased
  requirements that leave something out ("only X", "X is the sole path");
- approval, stop, wait and permission steps, and new reasons to ask a human;
- caps, limits, scope boundaries, and code conditions that refuse or skip work;
- tests that assert a refusal or a limit.

## Phase 2: Find each source

Each constraint needs a source that covers its case:

- an accepted decision record (ADR, PDR or WDR) whose scope includes the case;
- the requirement of the issue or plan that the change delivers;
- the accountable human's own words (WDR 009), quoted with date and the question they answered;
- a verified platform, API, storage or protocol contract, or a reproduced correctness or security
  boundary.

Needs no further source: routine input validation and a demonstrated capability limit. Neither may
be turned into a new approval step.

Is a finding:

- **unsourced** — no source covers the constraint;
- **extrapolated** — the source covers a narrower case than the constraint claims;
- **proposal stated as rule** — a draft or proposed choice written as decided;
- **new approval step without authority** — a request for permission that the task or an accepted
  record already gives.

## Phase 3: Self-audit

- For each "pass", did you read the source, or only see that one was cited?
- Did you include positively phrased limits, tests and code conditions, not only prose with
  "never" or "must not"?
- Did you report any constraint the diff did not add or change? Remove it.

## Output format

```
## Scope
- Branch: [branch name]
- Base: [full base hash]
- Head: [full head hash]
- Kind: full review / recheck of [earlier finding IDs]
- Files changed: N

## Constraints
| # | File | Constraint (quoted) | Kind | Source | Covers this case? |
|---|------|---------------------|------|--------|-------------------|
| 1 | ... | ... | refusal/approval/cap/exclusion/test/code | record, requirement, quote or contract | yes/no/narrower |

## Findings
| ID | Severity | File and location | Constraint # | Finding | Missing or narrower source | Recommended Fix |
|----|----------|-------------------|--------------|---------|----------------------------|-----------------|
| R1 | high/medium | ... | row of the Constraints table | unsourced/extrapolated/proposal stated as rule/new approval step | the authority that is absent, or the narrower case it covers | remove, narrow, cite, or record the decision |

## Coverage
- Read in full / in part / not read, with the reason
- Reviewer: [model, effort setting, tool limits]

## Summary
- Constraints reviewed: N
- Findings: N (X high, Y medium)
- Recommendation: APPROVE / REQUEST CHANGES
```

**Do not approve with any high finding.** An empty constraints table is a valid result when the
diff adds no constraint.
