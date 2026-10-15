# Report templates

## inventory.md

Start with the audit header, then one table for each root cause.

```markdown
# Refusal audit inventory

- Repository: <owner/name>
- Commit: <full Git object ID>
- Owner's request: <date, and a locator>
- Auditor: <agent and its model family>; second reader, if one ran: <agent and its model family>
- Roots: <count>; rows: <count>

## Root R01: <short name of the root text>

Root text: `<file>:<line>` "<exact text>"

| Row | File:line | Text | Kind | Effect (example of blocked work) | Read by | Source (locator, revision, quote) | Provenance | Disposition and reason |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| C001 | ... | ... | ... | ... | ... | ... | ... | keep / narrow / cite / remove / owner decision, with the reason |
```

## proposals.md

One block for each root that is not "keep".

```markdown
## Root R01: <short name>

- **Current text and copies:** <each file:line, with the exact text>
- **Effect:** <what it stops, with one concrete example of legitimate work it blocks>
- **Source:** <what you found, with its locator; or "not found", and where you looked>
- **Change:** <the exact new text, removed text or citation, for each copy>
- **What stays:** <the parts that keep a source, and why>
- **Order:** <fix the source text first, then the copies; name the repositories in order>
- **Tests:** <the positive test that shows the work now runs, where code or tests change>
```

## owner-decisions.md

Only the items that need the owner. One item at a time, each with a recommendation.

```markdown
## Recommendation: <the action, in one line>

**What:** the change, its source, and what gets recorded.

**Why:** the trap it removes, with the example of blocked work.

**What stays:** the part that may protect something, and why we keep it or ask.

**Disagreements:** if a second reader ran, any point where the two readers still disagree.
```

## coverage.md

```markdown
| Reader | Read in full | Read through search only | Not read | Reason |
| --- | --- | --- | --- | --- |
```

Also record each search that returned nothing, with the known-positive check that proves the
search can find a match.
