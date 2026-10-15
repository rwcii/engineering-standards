---
name: handoff
description: Write a session handoff — an immutable, timestamp-named snapshot of the current work's state so the next session (or agent) can resume with full context. Use at the end of a session, when context is filling up, before a risky/long operation, or whenever the user asks to "hand off", "write a handoff", or "save state". Each run writes a NEW file; it never edits a prior one.
---

# Handoff — Snapshot the Current Work State

Write a **fresh, timestamp-named handoff document** capturing everything the next session
needs to resume this work without re-deriving it. Each handoff is an **immutable snapshot**:
a new file every time, so the directory is a history you can fall back on. You do **not** edit,
purge, or consolidate prior handoffs — the newest file is the current state; the older ones are
the trail.

The reader is the **next agent**, not a human. Optimize for fast, lossless context recovery,
not for prose. Be terse, concrete, and structured. Bullet lists and short fragments over
paragraphs. Include exact identifiers (branch names, commit SHAs, PR numbers, file paths, IDs,
URLs) — they are what make resumption cheap.

> **Adopting this skill:** project-agnostic as written — it uses a generic gitignored
> `_handoff/` working directory and standard `git`/`date`, and bootstraps itself on a fresh
> checkout (Step 1). Adopt it as-is; the only project-specific touch is the *Pointers* section,
> which should name your repo's authoritative docs (architecture overview, record set, dashboards).

## Arguments

- `$ARGUMENTS` — optional: a short label or focus for this handoff (e.g. a sprint/spike name,
  or "pre-refactor"). If given, work it into the filename suffix and the title.

## When to run

- At the **end of a working session**, or when context is getting full and a summary is imminent.
- **Before** a risky, long, or destructive operation, as a restore point.
- Whenever the user asks to hand off / save state / write a handoff.

---

## Procedure

### 1. Ensure the handoff area exists and is ignored

**Do not assume the `_handoff/` directory or its gitignore entry already exist.** On a fresh
clone, a new worktree, or a repo that has never used this skill, you must create them. Run this
idempotent bootstrap **every time** — it is a no-op when already set up, and self-heals when not:

```bash
# 1. Create the handoff dir if missing (fresh checkout / new worktree).
mkdir -p _handoff

# 2. Ensure it's gitignored. Creates .gitignore if absent (>> creates the file); appends the
#    entry only if neither '_handoff' nor '_handoff/' is already present. Skip if not a git repo.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  grep -qE '^_handoff/?$' .gitignore 2>/dev/null || printf '%s\n' '_handoff/' >> .gitignore
fi
```

The handoff area is **working scratch, never committed** — the bootstrap guarantees that even
on a directory that was just pulled and has no `_handoff/` set up. (If `_handoff/` is somehow
already tracked in git, stop and tell the user rather than writing secrets/state into a tracked,
pushable path.)

### 2. Get a real timestamp from the shell — do not trust your own clock

```bash
date +%Y-%m-%d-%H%M%S
```

Name the file `_handoff/<timestamp>-handoff.md` (append `-<label>` before `-handoff` if
`$ARGUMENTS` was given), e.g. `_handoff/2026-06-15-143007-handoff.md`. The format is
sortable so the newest handoff is always last alphabetically.

### 3. Seed from the most recent prior handoff (continuity, not duplication)

```bash
ls -1 _handoff/*-handoff.md 2>/dev/null | tail -1
```

If one exists, read it and **carry forward** anything still true or still outstanding (open
tasks, undelivered scope, live decisions). The new handoff is a **complete fresh snapshot**,
not a diff — restate current reality in full; don't write "see previous handoff."

### 4. Write the new handoff file

Write the file with the sections below. Omit a section only if it genuinely has no content,
and say so in one line rather than padding. Keep every claim **true as of now** — verify
volatile facts (branch, PRs, build/test status) against the actual tool/command output before
writing them, don't assert from memory.

```markdown
# Handoff — <project/work name> — <timestamp> [<label>]

## Where things stand
- Project/sprint/spike: <what this work is, in one or two lines>
- Branch / git: <current branch, base, tip SHA, dirty/clean>
- Open PRs / reviews: <numbers, titles, merge order/dependencies, state>
- **Delivered this session/sprint:** <bullets — concrete, with identifiers>
- **Remaining to deliver:** <bullets — what's not done yet, in priority/sequence order>

## Goals
- <the goal(s) of this session / sprint / spike — what success looks like at the top level>

## Success criteria
- <the specific, checkable conditions that mean the work is done / acceptable>

## In flight (resume here)
- Immediate next action: <the single first thing the next session should do>
- Blockers / open decisions awaiting input: <each with enough context to act>
- Anything mid-operation (uncommitted edits, a running job, a half-applied change)

## Carry-forward context (not recorded elsewhere)
- Knowledge, findings, reference docs, URLs, IDs, decisions-in-progress, or rationale that
  matter to the next session and are **not** already in the repo, records, or memory. This is
  the most valuable section — capture what would be expensive or impossible to rediscover.

## Pointers (authoritative sources — read, don't restate)
- The repo/record/doc paths that hold the durable truth, so this handoff points rather than
  duplicates (e.g. the architecture overview, the relevant specs/records, dashboards, tickets).
```

### 5. Confirm

Report the path written and a one-line summary of what it captures. Do not read it back to
verify — the write tool errors if it failed.

---

## Rules

- **New file every time. Never edit or delete a prior handoff** — they are the history.
- **Agent-oriented, terse, concrete.** No human-presentation polish. Identifiers over adjectives.
- **Point, don't duplicate.** The handoff orients toward the authoritative repo/records/memory;
  it does not restate what those already hold. The exception is the *carry-forward* section —
  knowledge not recorded anywhere else belongs here.
- **Durable vs. transient.** A fact true across *many* future sessions (a standing preference, a
  stable project invariant) belongs in **memory** (`MEMORY.md`), not only in a handoff snapshot.
  The handoff is for *this* work's state and the context needed to resume *it*.
- **Truth over completeness.** Every line must be accurate as of write time; verify volatile
  facts against real command output first. A confidently wrong handoff is worse than a short one.
