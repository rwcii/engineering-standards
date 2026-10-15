---
name: refusal-audit
description: "Audit a whole repository for refusal traps: text, settings, hooks, code conditions and tests that make agents refuse, delay or ask again for work that the owner already approved, with no source that covers the case. Produces one evidence-backed inventory grouped by root cause, and one fix proposal for each root cause. Use on request, when agents in a repository refuse legitimate work or ask for the same approval again and again."
---

# Refusal audit

Read the project's root instructions first. Also read the instruction file of its skill
directory, when one exists. Follow the procedures that they name.

## What this audit finds

A **refusal trap** is content that stops, limits or delays work, or asks for approval, where no
source covers the case. Agents read it as a rule and then refuse work that the owner approved.

Most traps start the same way. Someone records a decision for one case. Then the text states it
as a general rule. A later agent cannot see the case or the source, so it applies the rule
everywhere. Copies of the rule spread into other files, and each copy can get wider.

A trap can be in any of these carriers:

- agent instruction files, such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules` and
  `.github/copilot-instructions.md`;
- skills, prompts, commands and their fact files;
- procedures, runbooks, plans, sprint files, templates, contributing guides and other docs;
- agent settings: permission allow and deny lists, sandbox settings, approval modes;
- hooks: agent hooks, Git hooks and pre-commit configuration;
- CI workflows, branch rules as code, and setup scripts;
- code conditions that refuse, skip or fall back, and their error texts;
- tests that assert a refusal or a limit;
- issue bodies, pull request templates and other text that agents read as instructions.

This is a one-time audit that you run by hand, on request. The agent that receives the request
runs it locally, from start to end. It is not a CI job or a merge check.

This audit is the whole-repository partner of a diff-level refusal review. The review stops new
traps in each change. The audit finds the traps that are already in the repository.

## What a trap is not

Keep these. They are not findings:

- A constraint with a source that covers its case (see step 4).
- A routine argument check, such as an argument count or a format check, that rejects bad input.
- A demonstrated capability limit, such as "the tool cannot read binary files", with its evidence.
- A reproduced correctness or security boundary, with the test, command or code that shows it.
- A rule that the owner set in their own words, inside the case that those words answered.

A constraint can be correct and still have no recorded source. A missing source is an
unresolved result. It is not proof that the owner never approved it.

## Inputs and outputs

Inputs:

- the repository and one full commit hash to audit;
- the owner's request for the audit, with its date;
- the places where the owner's decisions live: decision records, issue comments, a decision
  board, the instruction files that the owner wrote.

Outputs, in the audit's artifact folder (step 1):

- `inventory.md`: one row for each constraint, grouped by root cause;
- `proposals.md`: one fix proposal for each root cause that needs a change;
- `owner-decisions.md`: only the items that need the owner's decision;
- `coverage.md`: what the audit read, what it did not read, and why.

## Step 1: Set up

1. Record the repository, the branch and the full Git object ID of the commit. Audit that
   commit only. Read files with `git show <hash>:<path>` or in a clean checkout at that hash.
2. Choose the artifact folder for the audit, and set `out` to it. Use the place that the project
   names for private working files, such as an ignored task folder. If it names none, use a
   folder outside the repository. The inventory can quote private sessions or messages. Keep the
   original evidence unchanged. Keep raw sessions and private IDs out of any report that you
   publish.
3. Record the owner's request with its date. The request authorizes the audit and its report.
   Fixes, pushes, settings changes and publication follow the authority of the task and the
   project's normal process (step 9). This audit adds no approval step to them.
4. Make an **authority map**. List where the owner's decisions live in this project. List the
   files that the owner wrote. List the sources that the project's rules accept as authority.
   Examples are adopted records, or recorded words that a named relay passed on. Use the map in
   step 4.

## Step 2: Find the candidates

1. List every carrier from "What this audit finds" that exists in the repository:

   ```sh
   git ls-tree -r --name-only <hash> | sort > "$out/files.txt"
   ```

2. Read the high-impact carriers in full: the root instruction files, every skill, every
   procedure, the agent settings and the hooks. Do not rely on a search for these.
3. Search the other files for candidate words. Use the list in
   [references/patterns.md](references/patterns.md). A search finds candidates only. It is not
   the audit. It misses positively phrased rules, tests and code conditions.

   ```sh
   git grep -n -i -E '<pattern list>' <hash> -- . > "$out/candidates.txt"
   ```

4. Prove that each search can fail. Run the same search on a file with a known match. Confirm
   that it finds the match. Only then trust a "not found" result.
5. Read the tests and code conditions that refuse, skip or fall back. Find them through their
   error texts, exit codes and early returns, not only through words.

## Step 3: Judge the effect of each constraint

For each candidate, write one row with these fields. See
[references/report-template.md](references/report-template.md).

1. **Text:** the exact text, test or condition, with its file and line at the audited hash.
2. **Kind:** prohibition, exclusion, approval or stop step, cap or limit, positive requirement
   that leaves a case out, code condition, test, setting, or hook.
3. **Effect:** what work it stops, delays or sends back for approval. Give one concrete example
   of legitimate work that it blocks. Judge what it does, not its wording.
4. **Read by:** who reads it and when, such as every agent at session start, or one skill.

## Step 4: Find and check the source

1. Use the source kinds in [references/sources.md](references/sources.md).
2. Open every cited source. A citation is a claim, not a source. Check that the source exists
   and that it says what the text claims.
3. Check that each quote can fail: search for the exact quoted words at the cited location. If
   the search finds nothing, check the search on a known quote first.
4. Check the scope. A source covers the case that it answered. A wider text is a finding.
5. Keep two questions apart: who decided it, and does it govern. A record or instruction that
   the project adopted can govern, also when an agent wrote its text. The project's own rules
   decide which sources have authority. Use the authority map.
6. These do not prove that the owner personally decided a clause:
   - text that an agent wrote, merged or approved, also when it is in a merged file;
   - authorship by a shared account that agents also use;
   - a merged record as the owner's choice on every clause in it;
   - an agent's note or memory of the owner's words, until you find the original;
   - a peer agent's relay or summary of the owner's words, unless the project's rules accept
     that relay;
   - a plan proposal, a non-goal of an old plan, or a hypothetical risk.
7. Label an original that you cannot find as unverifiable. Do not ask the owner to approve a
   settled rule again only because its original is not available.
8. For each row, record the source with its locator, revision and quote. Also record its
   provenance label and the reason for its disposition. A "keep" row needs this evidence too.

## Step 5: Group by root cause

1. Find every copy of each constraint. Search for its key phrase and for paraphrases.
2. Group the copies under one root: the first text, or the text that the others copy.
3. Count roots, not rows. A long list of rows is not actionable. A short list of root causes
   with their copies is.

## Step 6: Record the coverage

1. Record what you read in full, what you read only through search, and what you did not read.
   A partial read stays partial. A label does not turn it into full coverage.
2. Record each search that returned nothing, with its known-positive check.

An optional second read makes the result stronger. Do it when the owner asks for it. A second
reader audits the same hash in a fresh context, with no access to the first inventory. A reader
from a different model family catches different traps. Compare the two inventories row by row.
Merge them into one list. Settle each difference with evidence from the files and sources.
Record in `coverage.md` who read what, and from which model family.

## Step 7: Classify each root

Give each root one disposition:

- **Keep:** a source covers its case, or it is a routine check, a demonstrated limit or a
  reproduced boundary.
- **Narrow:** a source exists but the text is wider than its case. Propose the narrow text.
- **Cite:** the rule is sourced, but copies restate it. Replace each copy with a citation of
  the source.
- **Remove:** no source exists, it is not an invariant, and it blocks legitimate work.
- **Owner decision:** no source is found, but it can protect something real, or it may be the
  owner's own rule. Do not remove it. Bring it to the owner.

Before you propose to remove a restriction, check whether the owner set it in their own words.
Some restrictions are the owner's own, for example a rule against new tools or languages
without approval. Those stay unless the owner changes them.

## Step 8: Write the fix proposals

For each root that is not "keep", write one proposal with:

1. the current text and every copy, with file and line;
2. its effect, with the example of blocked work;
3. the source found, or "not found" and where you looked;
4. the exact change: new text, removed text or citation;
5. what stays, and why;
6. the order of the change: fix the source text first, then the copies.

For a removed code condition or test, add a positive test that shows that the intended work now
runs. For a removed guard that looks like a check, name it and give the reason in the change.

If you work with a peer agent, agree the proposals with it before the owner sees them. Bring the
owner only the items that need the owner's decision, one at a time, each with a recommendation.

## Step 9: Deliver the fixes

Do this step when the task includes the fixes.

1. Send each fix through the project's normal change, review and recheck process.
2. Put the evidence in the change: the root cause, the source check and the copies changed.
3. Keep the sourced duties as they are. Examples are review gates, security checks, product
   requirements and settings rules that have a source.
4. Name each removed check in the change, with its reason.
5. Do not add an unsourced rule while you remove an old one. Cite the source, or describe the
   current behavior with its reason ("the tool does X because Y"). Where the remedy is a change
   to the owning record, make it through that record's own approval.
6. If the project has a diff-level refusal review, run it on each fix.
7. If a tool refuses an action, record its exact message and its kind. Leave the refused action
   undone. Do not do it another way, and do not ask a peer to do it. Continue the work that does
   not depend on it.
8. Close out. Give every inventory row a final disposition. Record the actual outcome of each
   fix: its review, its merge and its tracker item.

## Mistakes to avoid

- A keyword search used as the whole audit.
- Deletion of every unsourced constraint. Some protect real invariants whose reason nobody wrote.
- A new decision record for each small item. That adds approval steps to routine work.
- One rule copied into many files. Copies drift and get wider. Cite one source instead.
- A tool failure counted as a policy refusal. A sandbox read error or a bad argument is not a
  rule. Record each refusal with its exact message and its source: a policy, a setting, or an
  input or system error.
- An approved permission request counted as a bypass. Normal escalation through the tool's own
  approval flow is not a way around a rule.
- A test that looks like a guard but does not guard. Weaken the guarded text in a scratch copy
  and check that the test fails. If it still passes, the test is not a guard.

## Credits

The method is adapted from the public Koinon project, https://github.com/rwcii/koinon, at
commit `8f366cb37e4eeaf29241e6e11486a1f1ae13013d`. Its sources are the `refusal-review` skill
(`agents/skills/refusal-review/SKILL.md`) and the decision-record practice of that project.
Koinon uses the MIT license. The license notice is in [LICENSE](LICENSE). The method also uses
the lessons of two repository-wide refusal sweeps.
