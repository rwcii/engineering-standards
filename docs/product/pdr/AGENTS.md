# AGENTS.md — Product Decision Records

## What This Directory Contains

Product Decision Records (PDRs) that capture **product behavior, user flows, and UX
contracts**. PDRs are the product counterpart to Architecture Decision Records (ADRs,
`docs/architecture/adr/`) and Workflow Decision Records (WDRs, `docs/engineering/wdr/`).

## When You Should Read These

- Before modifying any multi-step user flow (onboarding, setup, a wizard)
- Before changing user-facing behavior or a product promise (what a feature guarantees)
- Before altering generated or templated user-facing content
- When `standards-review` runs Phase 2b (PDR Compliance)

## Key Constraints

- **PDRs capture product decisions, not architecture.** If the decision survives a
  complete rewrite (new language, new framework) it belongs here. If it survives a
  complete product pivot (new features, new flows) it belongs in `docs/architecture/adr/`.
  If it survives **both** — because it governs how the work is done — it belongs in a
  Workflow Decision Record (`docs/engineering/wdr/`).
- **No line numbers, no AI attribution, no volatile implementation details.** See
  `PDR_PROCESS.md` § "What PDRs Must NOT Contain."
- **PDRs and ADRs often come in pairs.** Cross-reference via `related_adrs` /
  `related_pdrs`. The ADR captures the mechanism; the PDR captures the behavior.

## File Locations

| File             | Purpose                                                     |
| ---------------- | ----------------------------------------------------------- |
| `PDR_PROCESS.md` | Process rules, template, lifecycle, ADR/PDR scoping criteria |
| `000-template.md`| Copy-ready PDR template                                      |
| `README.md`      | Index of all PDRs                                            |
| `NNN-*.md`       | Individual PDR files                                         |

## Conventions

- Sequential numbering (001, 002, …) — check `README.md` for the next number
- Kebab-case filenames, 3–6 words after the number
- YAML frontmatter with `pdr`, `title`, `status`, `created`, `updated`, `authors`,
  `tags` (all required)
- Status lifecycle: `draft → under_review → accepted → modified → deprecated/superseded`
- Commit messages: `docs(pdr): add/update NNN [title]`

## Checklist Before Modifying

- [ ] Read `PDR_PROCESS.md` for the full template and scoping rules
- [ ] Check `README.md` index for the current highest number
- [ ] Verify the decision belongs in a PDR, not an ADR or an issue
- [ ] Update `README.md` index when adding or changing status
