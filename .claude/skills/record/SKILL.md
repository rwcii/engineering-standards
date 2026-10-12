---
name: record
description: Create or update a decision record (ADR / PDR / WDR, including point-versions) — following the template, numbering, and house rules, and keeping the README index, cross-references, and the Document History table all in sync. Use whenever adding or changing an ADR/PDR/WDR, or when asked to "write a record", "add an ADR/PDR/WDR", or "capture this decision".
---

# Record — Author and Maintain Decision Records

Decision records are the source of truth for this repository (AGENTS.md). This skill creates and
maintains them so the set stays internally consistent, cross-referenced, and house-rule clean.
It does **not** replace the independent `standards-review` and `refusal-review` (WDR 005) — run
them before pushing.

> **Adopting this skill:** the authoring discipline below is universal; the concrete pointers are
> this repo's realization. This template ships the three record types (ADR/PDR/WDR), the per-module
> trio convention (`README.md` + `AGENTS.md` + thin `CLAUDE.md`), and the README index per module.
> An adopting project supplies its own **enforcement** (a house-rule lint, a CI gate) and may add
> layers this template does not — e.g. a component-spec module or a record map / architecture
> overview. Swap the references for your project's equivalents; the rules and the record shape carry.

## The three record types (+ optional specs)

Pick the type with the **three-question test** (`WDR_PROCESS.md`):

- **ADR** — `docs/architecture/adr/` — *how the system is built* (structure, patterns, boundaries).
  Survives a product pivot; changes in a rewrite.
- **PDR** — `docs/product/pdr/` — *how the product behaves* (flows, UX, voice). Survives a rewrite;
  changes in a pivot.
- **WDR** — `docs/engineering/wdr/` — *how the work is done* (workflow, gates, agent loop). Survives
  **both** a rewrite and a pivot.

Some adopting projects add a **component-spec** layer (e.g. `docs/specs/`) that *cites ADRs and
never re-decides them*, often using a `**Status:**` bold-header convention instead of YAML
frontmatter. If yours does, the same authoring discipline applies — follow that module's own
`AGENTS.md` convention.

If a candidate has no genuine alternatives, it is **not a record** — it is a tip (goes in an
`AGENTS.md`) or enforcement (tooling/CI).

## Before you write

1. Read the target directory's `AGENTS.md` (the scoped rules live there, per the per-module trio
   convention) and the process doc (`ADR_PROCESS.md` for ADR/PDR, `WDR_PROCESS.md` for WDR).
2. If your project keeps a **record map or architecture overview**, read it — it is the ownership
   source of truth. (This template tracks ownership via each module's `README.md` index.)
3. Allocate the number from the directory's `README.md` index: next sequential `NNN`, or a
   **point-version `NNN.N`** when the record realizes/extends a parent (set `parent_adr`/`parent_wdr`).
   Point-versions capture a sub-decision under a parent — this repo uses them for, e.g., ADR 001.1–001.5.

## Creating a record

- File name: `NNN-title-in-kebab-case.md` (3–6 words after the number); point-versions `NNN.N-…`.
- **Frontmatter** (ADR/PDR/WDR): all required keys for the type, exactly as the process doc
  specifies (`adr`/`pdr`/`wdr`, `title`, `status`, `created`, `updated`, `authors`, `tags`, `related`,
  and the supersession/review keys; `parent_*` on point-versions). The process doc is the source of
  truth for the key set — match it.
- **Body** (the established shape): Executive Summary → Table of Contents → Problem Context
  (Problem / Requirements / Scope) → one section per Decision (Decision / Alternatives Considered /
  Rationale / Enforcement / Trade-offs Accepted) → Conclusion → Document History.
- **Cross-reference, don't restate** (DRY single-ownership): name the owning record and defer.
- **Sync the index**: add the record to the directory `README.md` index (and any record map your
  project keeps). Update reciprocal `related` frontmatter and add a Document History row to any
  record whose ownership/cross-refs you touched.
- **New major module?** Add the per-module trio — `README.md` + `AGENTS.md` + thin `CLAUDE.md`
  (`@AGENTS.md`).

## Updating a record

- Make the edit, **add a Document History row** (date + what changed and why), and bump `updated`.
- Keep cross-references, the README index, and any record map consistent with the change.
- Edits to a **universal / principle-level** record should stay principle-level; push project
  specifics to a point-version (`NNN.N`) or to enforcement, not into the universal text.

## House rules (hard)

- **No AI/bot attribution** anywhere — authors, bodies, commits. The author is the human (WDR 009).
- **No line numbers or line counts** — reference file paths, symbol names, section anchors, record numbers.
- **No volatile detail** (variable names, byte/test counts, prices) — records must be durable.
- **No references to scratch / working-only artifacts** (e.g. the gitignored `_handoff/` snapshots,
  or non-vendored draft section numbers) in durable records — name the concept, not the transient file.

## Before you finish

1. Run your project's **house-rule lint** if it has one — the cardinal rules above are mechanically
   checkable, and an adopting project supplies the linter/CI gate that enforces them.
2. When the branch is ready, run the independent `standards-review` and `refusal-review` (WDR 005)
   over `develop..HEAD`.
3. Commit message: `docs(adr): …` / `docs(pdr): …` / `docs(wdr): …`.

## References

- `docs/architecture/adr/AGENTS.md`, `docs/product/pdr/AGENTS.md`, `docs/engineering/wdr/AGENTS.md`
- `docs/architecture/adr/ADR_PROCESS.md`, `docs/engineering/wdr/WDR_PROCESS.md`
- WDR 005 (independent review), WDR 008 (context & memory engineering), WDR 010 (branch/merge);
  your project's record-hygiene lint (enforcement).
