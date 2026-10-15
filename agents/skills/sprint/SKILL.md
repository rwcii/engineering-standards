---
name: sprint
description: Plan and scope a deliverable as a sprint — author a decision document (problem / acceptance criteria / constraints, written separately and tight) BEFORE any technical spec, fix the testing strategy and definition-of-done at kickoff, chunk the work into sequential, self-contained scoped deliverables each genuinely complete before the next starts, and adversarially review the plan with clean subagents before execution. Use when asked to "plan a sprint", "scope this feature/build", "kick off the build", or before starting any non-trivial multi-step deliverable.
---

# Sprint — Scope a Deliverable Before You Build It

Plan a deliverable so the **decision is settled, "done" is agreed, and the work is chunked**
before a single line of the implementation spec is written. This is the front door to any
non-trivial build: it produces a *fully scoped deliverable* — a decision document, a
definition-of-done, a chunk plan, and one focused technical spec per chunk — that someone (a
human or a fresh agent context) can execute chunk by chunk without re-deriving intent. The plan
is **adversarially reviewed by clean subagents** before any of it is built, with every material
finding resolved, and the skill **asks the owner** rather than guessing whenever scoping needs
input the records do not already answer.

It does **not** write production code. It produces the scoped plan the code is then written
against. In a records-driven repo it sits **on top of** the decision records: a sprint
*realizes* ADRs/PDRs/WDRs (and any component specs) — it references them, it never re-decides them.

> **Adopting this skill:** the protocol below is stack-agnostic. The concrete references
> (an architecture overview / record map, the ADR/PDR/WDR records, WDR 004 testing discipline,
> WDR 010 branch/merge, a `gate` command, a record-hygiene lint) are this repo's realization —
> swap them for your project's equivalents. The three pillars, the gates, and the artifact set
> are universal. The sprint artifacts live under `docs/sprints/NNN-<slug>/`, created on first use.

## The three pillars (non-negotiable)

1. **Decision before spec.** The sprint opens with a **decision document** — three artifacts,
   written **separately** and kept **tight and factual**: the *problem statement*, the
   *acceptance criteria in plain language*, and the *constraints*. No solution design lives
   here. The technical spec is written **after** this is approved, and **references** these
   externals rather than repeating them.
2. **Testing is decided at kickoff, not at the end.** Before the implementation spec exists,
   agree on what **"done"** means: a unit-test coverage threshold, the integration points that
   must be verified, and the edge cases that must be covered. This is the acceptance gate every
   chunk is measured against — so you discover a wrong turn at chunk 1, not at the finish line.
3. **Chunk the deliverable.** One massive sprint becomes a sequence of **scoped, self-contained
   deliverables**, ordered by dependency. Each chunk is **genuinely complete** — builds, tested
   to its slice of the definition-of-done, reviewable, mergeable — **before the next starts**.
   Each is sized to execute in a clean context reading only the decision doc, the DoD, and that
   one chunk's spec.

## What this produces (the fully scoped deliverable)

Under `docs/sprints/NNN-<slug>/`:

| Artifact | Pillar | Contents |
|----------|--------|----------|
| `decision.md` | 1 | The three externals, in three separate sections: **Problem**, **Acceptance Criteria** (plain language), **Constraints**. Tight, factual, solution-free. |
| `definition-of-done.md` | 2 | Coverage threshold; integration points to verify; edge cases to cover; how each is exercised (the gate). Agreed at kickoff. |
| `sprint.md` | 3 | The chunk plan (ordered chunks + per-chunk outcome and done-criteria), and the technical lead-in that **references** `decision.md` + `definition-of-done.md` and the locked records — never restates them. |
| `chunks/NN-<slug>.md` | 3 | One focused technical spec per chunk: the approach, interfaces/shapes, and the test plan realizing that chunk's slice of the DoD. References the externals; specifies only this chunk. |
| `review.md` | review | The adversarial review log: each clean-subagent finding, its severity, and its disposition (fixed → what changed, or rejected → why). The audit trail that the plan was attacked and the issues resolved before execution. |

## Arguments

- `$ARGUMENTS` — the deliverable to scope (a feature, a build step, a subsystem). If absent,
  ask the owner what the sprint is for before proceeding.

## House rules (hard — inherited from the repo contract)

- **Never guess; never decide for the owner.** When scoping needs input you do not have — an
  ambiguous requirement, an unstated boundary, a genuine fork, a missing constraint, an unknown
  acceptance threshold — **stop and ask the owner clarifying questions before proceeding**. Do
  not fill a gap with an assumption and build on it. A plan is only as sound as the answers it
  rests on; a guessed answer silently corrupts every chunk downstream. Open questions that
  block correct scoping are themselves a reason to pause a gate, not to push past it.
- **No AI/bot attribution** anywhere (authors, bodies, commits). The author is the human.
- **Reference, do not restate** (DRY single-ownership): the spec cites `decision.md`, the DoD,
  and the owning ADR/PDR/WDR/spec — it does not copy them. A constraint that is already a locked
  decision is cited by record number, not re-argued.
- **No volatile detail** in the durable artifacts (no line numbers, no byte/test counts as
  prose, no invented variable names) — reference paths, symbols, section anchors, record numbers.
- A sprint **realizes** decisions; it does not make them. If scoping surfaces a real fork with
  genuine alternatives, stop and capture it with the `record` skill first, then reference it.

---

## Phase 0 — Frame and locate

1. Read the relevant **decision records and specs** the deliverable touches — your project's
   architecture overview / record map first (if it has one), then the owning ADRs/PDRs/WDRs (and
   any component specs). The sprint inherits their constraints; it must not contradict or duplicate them.
2. Allocate the sprint number: next sequential `NNN` under `docs/sprints/`. Create
   `docs/sprints/NNN-<slug>/`. Keep the sprint anchors (`decision.md`, `definition-of-done.md`,
   `sprint.md`, `review.md`) under `docs/sprints/` — if your project enforces a home for these
   artifacts (a record-hygiene lint / CI gate), that is what it checks. (Chunk specs sit beside
   those anchors and are not separately location-gated.)
3. Confirm the deliverable's boundary with the owner in one or two sentences before drafting —
   a sprint scoped to the wrong altitude wastes the whole plan.
4. **Surface every open question first.** Before writing `decision.md`, list what you need from
   the owner that the records and the request do not already answer — ambiguous requirements,
   unstated non-goals, the acceptance thresholds (including the coverage bar), unresolved forks.
   **Ask, and wait for answers.** Do not begin drafting on a guessed answer; an unknown that
   blocks correct scoping pauses the sprint until the owner resolves it. (Use the question tool
   for genuine forks; record the answers in `decision.md` so the basis is explicit.)

## Phase 1 — Decision document (Pillar 1) → **GATE A**

Write `decision.md` as **three separate sections**, each tight and factual:

- **Problem statement.** What is wrong / missing / needed, for whom, and why now. The current
  state and the gap. **No solution, no design** — if a sentence describes *how*, it belongs in
  the spec, not here.
- **Acceptance criteria (plain language).** What must be observably true for this to be done,
  stated so a non-implementer can check each one. Outcomes, not mechanisms. These are the
  contract the chunks collectively satisfy.
- **Constraints.** The boundaries: explicit non-goals; locked decisions to honor (cite the
  ADR/PDR/WDR/spec by number — do not re-argue them); dependencies and sequencing; and any
  performance, security, compatibility, or licensing limits. What the sprint may **not** do is
  as load-bearing as what it must.

**GATE A — stop and get the owner's approval of `decision.md` before writing any spec.** Use
plan mode (or an explicit confirmation) for this gate. The decision document is the thing the
whole sprint references; getting it wrong is the expensive failure.

## Phase 2 — Definition of done (Pillar 2)

With `decision.md` approved, write `definition-of-done.md` **before** the technical spec:

- **Coverage threshold** — the unit-test coverage bar the deliverable must clear (a number),
  and where it is measured.
- **Integration points to verify** — the named seams (other modules, real datastores, the wire
  protocol, external services) that must be exercised end-to-end, not mocked away.
- **Edge cases to cover** — the enumerated adversarial/boundary inputs and failure modes that
  must have tests (align with WDR 004 — verification & testing discipline: conformance-first,
  plus fuzz/differential coverage at untrusted-input boundaries).
- **The gate** — the concrete command(s) that prove "done" (your project's build/test/gate
  command, plus any conformance/adversarial suites). Each chunk inherits the slice that applies to it.

## Phase 3 — Chunk plan + per-chunk specs (Pillar 3) → **GATE B**

1. **Decompose** the acceptance criteria into a sequence of **scoped, self-contained chunks**,
   ordered by dependency. Each chunk:
   - delivers one coherent, demonstrable outcome;
   - carries its own slice of the acceptance criteria and the definition-of-done;
   - is **complete before the next starts** — builds, passes its DoD slice, is reviewable and
     mergeable on its own (one feature → squash → `develop` PR per chunk, WDR 010);
   - is sized so a fresh context can execute it reading only `decision.md`, the DoD, and that
     chunk's spec — **no carried-over working memory between chunks**.
2. Record the ordered chunk list in `sprint.md` (each row: outcome, the criteria it satisfies,
   its done-criteria, its dependencies). `sprint.md` opens with a short technical lead-in that
   **references** `decision.md` and the DoD and the owning records — it does not restate them.
3. For each chunk, write `chunks/NN-<slug>.md`: the focused technical specification for that
   chunk only — design, interfaces/data shapes, and the test plan realizing its DoD slice — all
   **referencing** the externals, never repeating them.

Do **not** present Gate B until the plan has passed adversarial review (Phase 3.5).

## Phase 3.5 — Adversarial review by clean subagents → resolve, then **GATE B**

The plan is attacked **before it is approved or built**. Spawn **clean subagents** — each given
**only** the artifacts (`decision.md`, `definition-of-done.md`, `sprint.md`, the `chunks/`) and
the records they cite, and explicitly **not** the planning conversation. A reviewer that shares
your working context rubber-stamps your intent; a clean one reviews what is actually written.
This is the planning-stage counterpart to the independent `standards-review`.

1. **Fan out distinct lenses** (one subagent each; add more for a large sprint). Each is told to
   find holes and default to skeptical — a finding is cheap, a wrong build is not:
   - **Problem↔plan coherence** — do the chunks, in sum, actually satisfy the acceptance
     criteria and solve the stated problem? What outcome is unaccounted for?
   - **Acceptance-criteria quality** — are the ACs observable, testable, complete, and
     non-overlapping? What success condition is unstated?
   - **Constraint & record fidelity** — does any part of the plan violate, contradict, or
     silently duplicate a cited ADR/PDR/WDR/spec or a stated constraint? What constraint is missing?
   - **Chunk independence & ordering** — is each chunk genuinely self-contained and
     complete-before-next, or is there hidden cross-chunk coupling, a wrong order, or a chunk
     that cannot be tested in isolation?
   - **Definition-of-done adequacy** — would the DoD actually catch a wrong or incomplete build?
     Which integration point or edge case is missing? Is the coverage bar measured where it matters?
   - **Hidden assumptions & unknowns** — what does the plan assume is true but never established?
     What is the riskiest unvalidated bet?
2. **Triage and resolve.** Collect findings into `review.md`. **Every finding is dispositioned**:
   - **Fixed** — amend the offending artifact (`decision.md` / DoD / `sprint.md` / a chunk spec)
     and note in `review.md` what changed. If a finding exposes a real decision with
     alternatives, capture it with the `record` skill and reference it.
   - **Rejected** — only with an explicit, written reason in `review.md`.
   Material (correctness-affecting) findings **block Gate B** until fixed or reasoned away.
3. **Re-review on material change.** If resolving findings altered the chunk boundaries, the
   acceptance criteria, or the DoD, run a fresh clean-subagent pass over the amended plan.
   Converge — iterate until a pass surfaces no new material issues.

**GATE B — present the adversarially-reviewed plan (`review.md` included) for the owner's
approval of the chunk plan + DoD before execution begins.**

## Phase 4 — Execute (chunk by chunk) → **GATE C (per chunk)**

Execution is a **separate, deliberate step** — this skill produces the plan; building is done
against it (often in fresh contexts, optionally fanned out to subagents per chunk).

- Take chunks **strictly in order**. For each: implement against its `chunks/NN-*.md`, satisfy
  its DoD slice, run the gate.
- **GATE C — a chunk is not started until the previous one is genuinely complete** (gate green,
  DoD slice met, merged). This is what keeps each context window clean and prevents half-built
  chunks from accumulating.
- If execution reveals the plan was wrong, return to the relevant artifact, amend it (with a
  Document History note), and re-gate — do not let the code and the plan drift apart.

---

## Using subagents and plan mode (scale to the deliverable)

- **Plan mode** is the natural vehicle for **Gate A** and **Gate B**: enter plan mode, present
  the decision document (or the chunk plan), and exit only on the owner's approval.
- **Subagents** parallelize where the work is genuinely independent:
  - Phase 1: one subagent drafts each of the three externals concurrently, then a synthesis pass
    tightens them and removes overlap (they must stay *separate* but consistent).
  - Phase 3: one subagent per chunk drafts that chunk's spec from the approved decision doc +
    DoD; a synthesis pass checks the chunk boundaries are clean and the order is right.
  - Phase 3.5: the adversarial review fans out **clean** subagents — one per lens — each given
    only the artifacts and the cited records, never this conversation, so the critique is
    genuinely independent.
  - Phase 4: one subagent (or worktree) per chunk during execution — but still **sequentially
    gated**, never overlapping an incomplete chunk.
- Scale the machinery to the deliverable: a small sprint is a single pass; a large one fans out.
  Never let parallelism blur the sequential **completion** guarantee of Pillar 3.

## Templates (compact starting points)

`decision.md`:

```markdown
# Sprint NNN — <deliverable> — Decision

## Problem
<current state, the gap, who needs it, why now — no solution>

## Acceptance Criteria
- <observable outcome a non-implementer can check>
- ...

## Constraints
- Honors: <ADR/PDR/WDR/spec NNN> (cited, not restated)
- Non-goals: <what this sprint will not do>
- Dependencies / sequencing: <...>
- Limits: <perf / security / compatibility / licensing>
```

`definition-of-done.md`:

```markdown
# Sprint NNN — Definition of Done

- Coverage threshold: <N%> measured by <command/where>
- Integration points to verify (real, not mocked): <named seams>
- Edge cases to cover: <enumerated boundary/adversarial inputs>
- The gate: <command(s) that prove done>
```

`chunks/NN-<slug>.md`:

```markdown
# Sprint NNN · Chunk NN — <outcome>

> References: decision.md (Problem / AC / Constraints), definition-of-done.md, <records>. Not restated here.

## Scope
<the one coherent outcome this chunk delivers>

## Approach
<design, interfaces, data shapes — this chunk only>

## Done-criteria (this chunk's slice)
- AC covered: <which acceptance criteria>
- Tests: <unit + the integration points / edge cases from the DoD that apply here>
- Gate: <command(s)>
```

## References

- `docs/sprints/AGENTS.md` — the scoped rules and layout for the sprint module (create it on
  first use, following the per-module trio convention).
- Your project's architecture overview / record map — the build order and the record/spec maps;
  a sprint usually realizes one build-order step.
- `record` skill — when scoping surfaces a genuine decision, capture it as an ADR/PDR/WDR first.
- WDR 004 (verification & testing discipline), WDR 010 (branch/merge: feature → squash → `develop`),
  your project's record-hygiene lint, `/standards-review`.
