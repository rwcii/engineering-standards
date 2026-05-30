# AGENTS.md — Architecture Decision Records

## What This Directory Contains

Architecture Decision Records (ADRs) that capture **how a system is built** —
structure, patterns, boundaries, infrastructure. ADRs are the architectural
counterpart to Product Decision Records (PDRs) in `docs/product/pdr/`.

## When You Should Read These

- Before changing how subsystems interact (service boundaries, data access, auth flow)
- Before introducing a new pattern, technology, or cross-cutting mechanism
- Before adding a new variant to an extensible system (provider, adapter, object type)
- When `standards-review` runs Phase 2 (ADR Compliance)

## Key Constraints

- **ADRs capture architecture, not product behavior.** If the decision survives a
  complete product pivot (new features, new flows) it belongs here. If it survives a
  complete rewrite (new language, new framework) it belongs in `docs/product/pdr/`.
- **Universal records (001.x) stay principle-level.** Do not write a specific
  toolchain into them — concrete lint rules, codegen, and build gates are each
  project's *enforcement*, recorded in that project's copy, not in the universal text.
- **No line numbers, no AI attribution, no volatile implementation details.** See
  `ADR_PROCESS.md` § "What ADRs Must NOT Contain."

## Numbering

| Range  | Meaning                                                        |
| ------ | ------------------------------------------------------------- |
| 001.x  | Universal code-architecture standards — keep as-is            |
| 002.x  | Tech stack by layer (frontend / api / backend-persistence)   |
| 003    | Reserved (Configuration & Deployment)                        |
| 004.x  | Database & data-handling specifics                           |
| 005    | Security (stub)                                              |
| 006    | Authentication (stub)                                        |
| 007+   | Project-specific architecture decisions                      |

## File Locations

| File             | Purpose                                                      |
| ---------------- | ----------------------------------------------------------- |
| `ADR_PROCESS.md` | Process rules, template, lifecycle, ADR-vs-PDR scoping      |
| `README.md`      | Index of all ADRs                                           |
| `NNN-*.md`       | Individual ADR files (`NNN.N-*.md` for point versions)      |

## Conventions

- Sequential numbering; check `README.md` for the next number
- Kebab-case filenames, 3–6 words after the number
- YAML frontmatter with `adr`, `title`, `status`, `created`, `updated`, `authors`,
  `tags` (all required); `parent_adr` required on point versions
- Status lifecycle: `draft → under_review → accepted → modified → deprecated/superseded`
- Commit messages: `docs(adr): add/update NNN [title]`

## Checklist Before Modifying

- [ ] Read `ADR_PROCESS.md` for the full template and scoping rules
- [ ] Check `README.md` for the current highest number
- [ ] Verify the decision belongs in an ADR, not a PDR or an issue
- [ ] For universal records, keep it principle-level; push stack specifics to Enforcement
- [ ] Update `README.md` index when adding or changing status
