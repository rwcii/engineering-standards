# Review Procedure

This is the review procedure of this repository. The Koinon skills `koinon-standards-review` and
`koinon-refusal-review` read it through the facts files in `.koinon/skills/`. The decisions behind
it are in [WDR 005](../wdr/005-independent-review-and-control-plane.md); this file gives the steps
and does not restate their reasons. An adopting project can copy this file and change the values
that are its own (base branch, where results go).

## When a review runs

- Before the push that opens a pull request, and again on each new head of that pull request.
- Each review binds one frozen commit: record the full hash of the head and of its base.
- Two lenses run, each with its own verdict (WDR 005, Decisions 1 and 4):
  - **standards**: the change against the ADR, PDR and WDR records, with the
    [standards lens](standards-lens.md);
  - **refusal**: every refusal, gate, limit or approval step that the change adds or changes
    has a source that covers its case, with the procedure of `koinon-refusal-review` and the
    [refusal lens](refusal-lens.md).
- The base branch is `develop`, read as `origin/develop`.

## Reviewer

- A fresh context that wrote none of the change and has no history of the authoring work
  (WDR 005, Decision 1). It reads the committed content in its own checkout at the head hash.
- Record the reviewer's model, its effort setting and its tool limits beside the verdict.
- A change to a gate document (see below) is judged by the rules at the base commit, read with
  `git show <base>:<path>`. A change does not judge itself by its own new rules.
- When the change adds or moves a gate document, so that it has no copy at the base, the reviewer
  judges it by the governing records at the base (WDR 005) and by the documents it replaces, read at
  the base. The head's new procedure, lens and facts only start and shape the review.

## Which tree to read

- An added file: read it at the head.
- A deleted file: read it at the base. A removed check, guard or rule is reviewable only there.
- A renamed, moved or replaced file: read both sides and compare them. Report what the new side
  drops, narrows or widens.

## Brief

Fill every field. Write "none" where a field does not apply. A brief with an empty field, or one
that names an input the reviewer cannot read, is not ready.

1. Repository, branch, base hash and head hash.
2. Kind: full review, or recheck. A recheck also gives the fix range, the ID of each earlier
   finding of this lens, the earlier report and the outcome of each finding.
3. Lens: standards or refusal, and the path of its instructions.
4. Scope: the changed paths, and anything out of scope with the reason.
5. Done criteria: the acceptance criteria that the change claims to meet.
6. Deciding records: the ADR, PDR and WDR records that the author found applicable.
7. Author check: what the author checked before the review, and the result.
8. Gate documents that the change edits, if any.
9. Report: where the reviewer writes its report.

## Severity and the merge block

Every finding takes one level of the WDR 005, Decision 2 scale:

| Severity | Meaning                                                                                         | Blocks merge? |
| -------- | ----------------------------------------------------------------------------------------------- | ------------- |
| critical | Breaks correctness, security or data integrity; or a control-plane check was weakened or disabled | Yes         |
| high     | A real defect, or a violation of an accepted record, likely to cause harm                       | Yes           |
| medium   | A genuine issue that should be fixed but is contained                                           | No (track)    |
| low      | A minor issue or smell                                                                          | No            |
| note     | An observation, not a defect                                                                    | No            |

The refusal lens uses two levels. **High**: a constraint with no source, one wider than its
source, a proposal written as a decided rule, or a new approval step without authority, when it
changes behavior. **Medium**: wording that overstates a sourced constraint, or an unsourced
constraint that changes no behavior.

A blocking finding stops the merge until it is fixed, or waived with a recorded justification by
the right approver (WDR 005, Decision 2).

## Results

- Keep each reviewer's full report unedited, in a local folder outside version control.
- A report names the full base and head hashes, the reviewer's coverage (read in full, in part,
  not read, with the reason), and for each finding a stable ID, its severity, its file and
  location, the record or rule it breaks, and the fix. An ID stays the same through the rechecks
  of that review (for example S1, S2 for standards and R1, R2 for refusal).
- Put the verdict (APPROVE, REQUEST CHANGES or BLOCK), the full head hash and the findings in the
  pull request's review summary. Before posting, scan the text for private data.
- Record the outcome of each finding: fixed, accepted with a reason, or moved to a tracked issue.
  A finding is never dropped silently.

## Recheck

After fixes, freeze the new head. A fresh reviewer reads the fix range, each earlier finding by ID
and the code each fix reaches. It states for each finding whether it is closed, and reports each
new finding that a fix adds. The base of the full review stays the base of every recheck.

## Gate documents

A change to one of these is a control-plane change (WDR 005, Decision 3) and gets the stricter
reading above:

- the decision records (ADR, PDR and WDR) and their `README.md` indexes;
- this file, [standards-lens.md](standards-lens.md) and [refusal-lens.md](refusal-lens.md);
- the facts files in `.koinon/skills/`;
- `AGENTS.md`, `CLAUDE.md` and each module's `AGENTS.md`;
- the `*_PROCESS.md` files and record templates;
- `.githooks/`, `scripts/` and `.github/`.
