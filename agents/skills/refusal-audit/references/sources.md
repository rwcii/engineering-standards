# Sources: what counts and how to check it

## Source kinds that can cover a constraint

These are the source kinds of the `refusal-review` skill. In the Engineering Standards kit, they
are those of WDR 005, Decision 4. They are repeated here so that the audit works when you copy
this skill alone. If your project defines its own source kinds, use those.

1. **A decision record** whose scope includes the case, at the status that its header gives. A
   draft or proposed record is not a decision.
2. **The requirement of the issue or plan** that the work delivers. It covers that work, not
   other work.
3. **The owner's own words**, quoted exactly, with the date, the question they answered and a
   locator. A complete record of an owner decision states four things:
   - the question it answered;
   - the options that were on the table;
   - the answer, quoted, with its date;
   - the reason and the scope: what it covers and what it does not.

   The question, options and reason help you find the scope. A clear, direct instruction of the
   owner still counts when no options or reason were recorded. Do not invent missing context.
4. **A verified platform, API, tool or storage contract**, with a link to its documentation or a
   test that shows it.
5. **A reproduced correctness or security boundary**: a command, a test or the code that shows
   what fails without the constraint.

A routine argument check or a demonstrated capability limit needs no further source. It never
becomes an approval step.

## What does not prove the owner's personal decision

These do not prove that the owner personally decided a clause. That is a separate question from
whether the text governs. A record or instruction that the project adopted can govern, also when
an agent wrote it. The project's own rules decide which sources have authority.

- Text that an agent wrote, also when a pull request merged it.
- Authorship by a GitHub or other account that agents also use. The account shows who posted,
  not who decided.
- A merged record as the owner's choice on every clause. The owner may have decided only one
  point in it.
- An agent's note or memory of the owner's words. Find the original before you rely on it.
- A peer agent's relay, summary or reading of the owner's words. It is a copy, unless the
  project's rules accept that relay.
- A plan proposal, or a non-goal of a finished plan.
- A hypothetical risk with no evidence.

## How to check a source

1. Open it. Do not trust the citation.
2. Find the exact quoted words at the cited location. Use an exact search.
3. Make the check able to fail. Run the same search on a quote that you know exists, and confirm
   that it finds it. Then a "not found" result means something.
4. Compare the scope. Write down the case that the source answered. A text that applies the
   source to a wider case is a finding.
5. Prefer primary sources. An issue body or the owner's message is better than an agent's
   summary of it.

## Provenance labels for the inventory

Use one label for each row:

| Label | Meaning |
| --- | --- |
| `owner` | The owner's words, with quote, date, question and locator. |
| `record` | A decision record with a status that makes it a decision. |
| `requirement` | The issue or plan that the work delivers. |
| `contract` | A verified platform, API or tool contract. |
| `boundary` | A reproduced correctness or security boundary. |
| `routine` | A routine argument check or a demonstrated capability limit. |
| `shipped` | Shipped in a named change; no owner decision found. |
| `memory-only` | Only an agent's note or memory holds it; original not found. |
| `not-found` | No source found. Name where you looked. |

`shipped`, `memory-only` and `not-found` are unresolved results. They are not proof that the
owner never approved the constraint.
