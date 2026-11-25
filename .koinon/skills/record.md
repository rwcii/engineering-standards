# Repository facts — record

## Version
1
## Skill
record
## Sources
- AGENTS.md
- docs/architecture/adr/ADR_PROCESS.md
- docs/architecture/adr/README.md
- docs/product/pdr/PDR_PROCESS.md
- docs/product/pdr/README.md
- docs/engineering/wdr/WDR_PROCESS.md
- docs/engineering/wdr/README.md

## Record kinds and folders
- ADR, how the system is built: docs/architecture/adr/, process ADR_PROCESS.md;
- PDR, how the product behaves: docs/product/pdr/, process PDR_PROCESS.md;
- WDR, how the work is done: docs/engineering/wdr/, process WDR_PROCESS.md.

Pick the kind with the three-question test of any `*_PROCESS.md`. Each folder has a `README.md`
index, an `AGENTS.md` with its scoped rules and a thin `CLAUDE.md`. Read the folder's `AGENTS.md`
before writing.
## Index and numbering rule
Take the next number from the folder's `README.md` index. A point version `NNN.N` refines its
parent record and sets `parent_adr` or `parent_wdr`. Allocate so that parallel work does not take
the same number (WDR_PROCESS.md § Concurrency-safe numbering). File names are kebab-case, 3–6 words
after the number.
## Record checks
No automated record check exists yet. Check by hand, and report each check as passed or failed:
- the frontmatter has every key that the kind's process document requires;
- the body follows the template of the process document;
- the folder's `README.md` index row matches the record's number, title and status;
- each changed record has a new Document History row and an updated `updated` date;
- each relative link that the change adds or changes resolves to an existing file;
- the cardinal rules of AGENTS.md hold: no AI or bot attribution, no line numbers or counts, no
  volatile implementation detail, no toolchain names in a universal record;
- no reference to a scratch or git-ignored working file, such as a handoff snapshot.
## Commit subject pattern
`docs(adr): ...`, `docs(pdr): ...` or `docs(wdr): ...` (AGENTS.md § Working Conventions).
