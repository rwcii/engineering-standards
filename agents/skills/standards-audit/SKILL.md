---
name: standards-audit
description: Audit a repository for latent decisions that should be captured as ADR, PDR, or WDR records but are not yet recorded. Use when bootstrapping the decision-record set in a newly adopted repo, when asked to find missing or candidate ADRs/PDRs/WDRs, or to surface undocumented architectural, product, or workflow decisions. Classifies each candidate by type and proposes a record with evidence.
---

# Standards Audit — Candidate Record Discovery

Scan a repository for **decisions that were made but never recorded**, and propose
the ADRs, PDRs, and WDRs that should capture them. This is the bootstrap counterpart
to `standards-review`: review checks a *diff* against existing records; audit mines
the *whole repository* for records that ought to exist.

> **Adopting this skill:** this is a stack-agnostic skeleton. The mining signals
> below are generic (files, comments, git history, config). Tune the path globs and
> the history greps to your stack, and — if your project has settled on specific
> areas — add them to the source map in Phase 1. The protocol and output format are
> universal.

## Arguments

- `$ARGUMENTS` — optional: a path or area to scope the audit to (defaults to the
  whole repository).

## When to run

- Right after vendoring this kit into an existing project, to seed the record set.
- Periodically, to catch decisions that shipped without a record.
- Before a large refactor, to make the prevailing decisions explicit first.

---

## MANDATORY PROTOCOL — READ THIS FIRST

These rules override everything else. Violating any one invalidates the audit.

1. **READ THE ACTUAL ARTIFACTS.** Propose a candidate only from something you have
   read — a file, a comment, a commit, a config. Cite the path (or commit) as
   evidence. A candidate with no evidence you actually read is a hallucination.

2. **PROPOSE DECISIONS, NOT TASKS OR TIPS.** A record captures a *decision with
   genuine alternatives* that the team anchors on and validates compliance against.
   If there was only one reasonable option, or it is a tip / how-to / bug fix, it is
   **not** a record — at most it is `AGENTS.md` guidance or a project's enforcement.
   Apply this **altitude gate** to every candidate before listing it.

3. **CLASSIFY BY THE THREE-QUESTION TEST, NOT BY TOPIC.** For each candidate:
   - Would it change in a complete **rewrite** (new language/framework)? → **ADR**
     (how the system is built).
   - Would it change in a complete **product pivot** (new features/flows)? → **PDR**
     (how the product behaves).
   - Does it survive **both**, because it governs how the team and its agents work?
     → **WDR** (how the work is done).
   Topic does not decide type: a security *threat-model* decision is an ADR; a
   security *review-gate* decision is a WDR.

4. **DEDUPLICATE AGAINST EXISTING RECORDS.** Read the current ADR/PDR/WDR indexes
   and records first. Do not propose a decision that is already recorded. If a
   decision *is* recorded but the code now contradicts it, report that as a
   **drift** finding instead (a stale record), not a new candidate.

5. **NO STALE-PRONE CONTENT IN PROPOSALS.** Proposed titles and decision statements
   carry no line numbers, no volatile details (specific counts, variable names), and
   no AI/bot attribution. Reference file paths, symbols, and record numbers.

6. **DO NOT WRITE THE RECORDS.** This skill *proposes* candidates and produces a
   report. Authoring a record from the template is a separate, deliberate step the
   human or a follow-up invocation takes.

---

## Phase 0: Scope & Inventory

1. Determine scope from `$ARGUMENTS` (a path/area) or default to the whole repo.
2. Inventory what already exists so candidates are genuinely new:

```bash
ls docs/architecture/adr/ docs/product/pdr/ docs/engineering/wdr/ 2>/dev/null
grep -rhniE "^(adr|pdr|wdr|title|status):" docs/*/*/ 2>/dev/null   # existing record frontmatter
```

3. Read the existing indexes (`README.md`) and skim each record's Executive Summary
   so you know what is already captured.

---

## Phase 1: Mine for Latent Decisions

Sweep the repository across complementary signals — each finds decisions the others
miss. Read what you find; do not infer from filenames alone.

**Stated rationale (any source).** README, `docs/`, design notes, `AGENTS.md` /
`CLAUDE.md`, and inline comments that explain *why*: "chose X over Y," "we do this
because…," "do not change this," "important:", "HACK", "for now." These are
decisions someone already articulated but never filed.

**Architecture (ADR candidates).** Module/package boundaries and dependency
direction; the data-access pattern; chosen frameworks/datastores that imply a
commitment; cross-cutting mechanisms (auth, error handling, config, logging);
registries / plugin systems / extension points; API or contract definitions; the
build and deployment shape.

**Product (PDR candidates).** User-facing flows and their states/transitions;
feature flags and toggles; UX, content, and voice conventions; tiers/pricing;
onboarding, notifications, and messaging behavior.

**Workflow (WDR candidates).** The `.claude/` surface (commands, skills, settings,
hooks); CI/CD pipelines and gates; pre-commit / lint / type / test gates; review
process and code ownership; branch and PR conventions; `AGENTS.md` guidance that is
actually a binding decision; agent autonomy/permission config; environment and
reproducibility setup (devcontainers, lockfiles, pinned toolchains); how "done" is
defined and verified.

**Cross-source signals.** Mine history and markers, then read the artifacts they
point to:

```bash
git log --oneline -200 | grep -iE "chose|decid|switch|migrat|replac|revert|adopt|standardi"
grep -rniE "TODO|FIXME|HACK|XXX|should (document|decide|revisit)" --include=*.* .
```

---

## Phase 2: Classify, Gate, and Deduplicate

For each raw candidate, in order:

1. **Altitude gate** — is it a meaty decision with genuine alternatives? If not,
   set it aside for the "Guidance, not records" appendix.
2. **Type test** — ADR / PDR / WDR via the three-question test (Protocol rule 3).
3. **Dedup** — already recorded? Drop it (or, if contradicted by the code, move it
   to the drift list).
4. **Recover the alternatives** — name what was plausibly chosen *against*. A
   candidate with no real alternative fails the altitude gate; remove it.

---

## Phase 3: Rank & Propose

For each surviving candidate, assign:

- **Type** and a **proposed number** (next free in that series; see the relevant
  `*_PROCESS.md`).
- A **title** and a one-line **decision statement**.
- The **apparent alternatives** (what it was chosen against).
- **Evidence** — the file paths / commits you read.
- **Priority** — `high` (load-bearing, drift-prone, or governs other work) /
  `medium` / `low`.

Prefer **fewer, meatier** candidates. If several findings are facets of one
decision, propose one record that subsumes them — do not inflate the count.

---

## Output Format

```
## Standards Audit
- Scope: [path or "whole repo"]
- Existing records: N ADR, N PDR, N WDR
- Candidates proposed: N (X ADR, Y PDR, Z WDR)

## Candidate ADRs (how the system is built)
| Proposed # | Title | Decision (1 line) | Apparent alternatives | Evidence | Priority |
|------------|-------|-------------------|-----------------------|----------|----------|
| 007 | ... | ... | ... | path(s)/commit(s) | high |

## Candidate PDRs (how the product behaves)
| Proposed # | Title | Decision (1 line) | Apparent alternatives | Evidence | Priority |
|------------|-------|-------------------|-----------------------|----------|----------|

## Candidate WDRs (how the work is done)
| Proposed # | Title | Decision (1 line) | Apparent alternatives | Evidence | Priority |
|------------|-------|-------------------|-----------------------|----------|----------|

## Drift — recorded but contradicted by the code
| Record | What the code now does | Evidence |
|--------|------------------------|----------|

## Guidance, not records (tips / how-tos / single-option)
- [item] — belongs in AGENTS.md or project enforcement, not a record

## Recommended order
- [which candidates to author first, and why]
```

Each accepted candidate is then authored from its type's template
(`ADR_PROCESS.md` / `PDR_PROCESS.md` / `WDR_PROCESS.md`) as a separate step.

---

## Running at scale

For a large repository, fan the mining out and merge: assign each record type (or
each top-level area) to its own pass, then deduplicate and classify the combined
set centrally so candidates are not double-counted. For objectivity, run the audit
from a fresh context rather than mid-task in a working conversation.
