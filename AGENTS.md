# AGENTS.md — Engineering Standards

## What This Repository Is

A portable, stack-agnostic system of decision records and a review gate, meant to
be **adopted by other projects** — copied, or cited against a pinned record list (WDR 002,
Decision 4). It contains:

- **ADRs** (`docs/architecture/adr/`) — how a system is built (structure, patterns, boundaries)
- **PDRs** (`docs/product/pdr/`) — how a product behaves (flows, UX contracts, voice)
- **WDRs** (`docs/engineering/wdr/`) — how the work is done (workflow, agent operating loop, review/enforcement gates, the record system itself)
- **The review procedure** (`docs/engineering/review/`) — when the standards review and the refusal review run, the brief, severity, results, and the two reviewer lenses
- **Skill facts** (`.koinon/skills/`) — this repository's values for the shared [Koinon](https://github.com/rwcii/koinon) skills; the skills themselves are not kept here (WDR 008, Decision 4)

## Skills

Agents use the Koinon skills installed on the machine. Each reads its facts file in
`.koinon/skills/`:

| Task | Skill | Facts |
| ---- | ----- | ----- |
| Standards review of a branch | `koinon-standards-review` | `.koinon/skills/standards-review.md` |
| Refusal review of a branch | `koinon-refusal-review` | `.koinon/skills/refusal-review.md` |
| Write or change a record | `koinon-record` | `.koinon/skills/record.md` |
| Find decisions with no record | `koinon-standards-audit` | `.koinon/skills/standards-audit.md` |
| Audit a repo for refusal traps | `koinon-refusal-audit` | `.koinon/skills/refusal-audit.md` |
| Plan a multi-PR deliverable | `koinon-sprint` | `.koinon/skills/sprint.md` |
| Run the checks of a change | `koinon-check` | `.koinon/skills/check.md` |
| Hand off or pick up work | `koinon-handoff`, `koinon-pickup` | `.koinon/skills/handoff.md`, `.koinon/skills/pickup.md` |

## The One Principle to Internalize

Records here are written at **principle level** and are **language-agnostic**.
State the decision and the rationale; do **not** bake in a specific toolchain.
Each adopting project supplies its own **enforcement** (lint, CI, codegen, build
gates) for its stack. If you find yourself writing `npm`, `go test`, a package
name, or a framework API into a *universal* record, stop — that belongs in a
project's enforcement section, not here.

## Cardinal Rules (apply to every record)

- **No AI/bot attribution** anywhere — authors, body, commits. Author is the human.
- **No line numbers or line counts** — they go stale. Reference file paths,
  symbol names, or record numbers.
- **No volatile implementation details** — specific variable names, byte counts,
  test counts. Records must be durable.
- **An ADR/PDR/WDR documents a decision with genuine alternatives.** If there was only
  one reasonable option, it's not a record — it's just how things are.

## Where Things Live

| Path                          | Purpose                                            |
| ----------------------------- | -------------------------------------------------- |
| `docs/architecture/adr/`      | ADRs + `ADR_PROCESS.md` + index `README.md`        |
| `docs/product/pdr/`           | PDRs + `PDR_PROCESS.md` + index `README.md`        |
| `docs/engineering/wdr/`       | WDRs + `WDR_PROCESS.md` + index `README.md`        |
| `docs/engineering/review/`    | Review procedure, standards lens, refusal lens (WDR 005) |
| `.koinon/skills/`             | Facts the Koinon skills read for this repository (WDR 008, Decision 4) |
| `scripts/setup-repo.sh`       | Apply the branch/merge policy to a GitHub repo (WDR 010) |
| `.githooks/pre-commit`        | Blocks direct commits to `main` (WDR 010)          |
| `CONTRIBUTING.md`             | How to fork/extend or contribute back; DCO sign-off |
| `.github/PULL_REQUEST_TEMPLATE.md` | Curated-contribution PR checklist             |
| `LICENSE`                     | MIT © Stratovera                                   |

Each module has its own `AGENTS.md` with the rules specific to that record type —
read it before adding or editing records there.

## Working Conventions

- **Numbering:** zero-padded sequential; point versions `NNN.N` for sub-decisions
  under a parent ADR or WDR. Check the module's `README.md` index for the next number.
- **Filenames:** kebab-case, 3–6 words after the number.
- **Frontmatter:** YAML block required on every record (see the module process doc).
- **Commits:** signed (SSH); messages `docs(adr): ...` / `docs(pdr): ...` / `docs(wdr): ...`.
- **Branching:** never commit to `main`. Work on a feature branch off `develop`;
  squash-merge feature → `develop`, then merge `develop` → `main`. Recorded in WDR 010;
  `.githooks/pre-commit` blocks direct commits to `main`. Run `scripts/setup-repo.sh`
  once per repo to apply the hook path and the GitHub-side branch/merge settings.
- **Index:** update the module `README.md` table whenever you add a record or
  change its status (hand-maintained until a generator is wired — WDR 002).

## Before You Add or Change a Record

- [ ] Read the relevant `*_PROCESS.md` for the template and scoping rules
- [ ] Confirm it's a *decision with alternatives*, not an issue or a how-to
- [ ] Confirm the type — built (ADR) / behaves (PDR) / how the work is done (WDR); see the three-question test in any `*_PROCESS.md`
- [ ] Keep universal records principle-level; push stack specifics to enforcement
- [ ] Update the module `README.md` index
