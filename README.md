# Engineering Standards

A portable, stack-agnostic system of **decision records** and an automated
**standards-review** gate, designed to be vendored into any project regardless
of language or framework.

It has three record types and a review gate:

- **Architecture Decision Records (ADRs)** — *how the system is built*: structure,
  patterns, boundaries, infrastructure. See [`docs/architecture/adr/`](docs/architecture/adr/).
- **Product Decision Records (PDRs)** — *how the product behaves*: user flows,
  UX contracts, voice/identity. See [`docs/product/pdr/`](docs/product/pdr/).
- **Workflow Decision Records (WDRs)** — *how the work is done*: the engineering
  workflow, the agent operating loop, the review/enforcement gates, and the record
  system itself. See [`docs/engineering/wdr/`](docs/engineering/wdr/).

Plus a [`standards-review`](.claude/commands/standards-review.md) command — an
independent preflight review agent that checks a branch against the records
before push/PR.

## The core idea: principle vs. enforcement

The decision records in this repository are written at **principle level** and are
deliberately language-agnostic. A universal record states *the decision and why*;
it does **not** prescribe a specific toolchain.

Each adopting project supplies its own **enforcement** — the concrete lint rules,
CI guards, codegen, type checks, and build gates that make the principle real on
*that* stack. A TypeScript monorepo enforces "Interface Boundaries" with package
`exports` maps and ESLint import rules; a Go service enforces the same principle
with internal packages and `go vet`. Same principle, different enforcement.

This separation is what makes the standards reusable. Copy the principle, write
your own enforcement.

## What's inside

```
.
├── docs/
│   ├── architecture/adr/     # Architecture Decision Records + process
│   ├── product/pdr/          # Product Decision Records + process
│   └── engineering/wdr/      # Workflow Decision Records + process
└── .claude/
    └── commands/
        └── standards-review.md   # independent preflight review protocol
```

### Baseline records

| Record  | Kind                                   | Status   |
| ------- | -------------------------------------- | -------- |
| ADR 001 | Code Architecture Standards (+ 001.1–001.5) | Accepted (universal) |
| ADR 002 | Tech Stack (+ 002.1/.2/.3)             | Template (fill per project) |
| ADR 003 | Reproducible Environments & Observability | Accepted (universal) |
| ADR 004 | Database & Data Handling               | Template (fill per project) |
| ADR 005 | Security                               | Draft stub |
| ADR 006 | Authentication                         | Draft stub |

ADR 003 (Reproducible Environments & Observability) is a universal
operational-standards record. Project-specific ADRs begin at **007**. PDRs are inherently
project-specific, so this repository ships only the PDR *process and template* —
no universal PDR content.

WDRs ship a universal baseline set of workflow / agentic-engineering standards,
beginning with WDR 001 (the decision-record taxonomy itself). See the
[WDR index](docs/engineering/wdr/).

## Adopting this in a project

1. **Vendor** `docs/architecture/adr/`, `docs/product/pdr/`,
   `docs/engineering/wdr/`, and `.claude/commands/standards-review.md` into your repo.
2. **Keep** ADR 001.x as-is (the universal code-architecture standards).
3. **Fill in** the templates for your stack: ADR 002.x (frontend / api /
   backend-persistence) and ADR 004.x (your data-handling specifics).
4. **Flesh out** the stubs (ADR 005 Security, 006 Authentication) when those
   decisions are made — or leave them `draft` until then.
5. **Add** your project's own ADRs from 007+ and your PDRs from 001.
6. **Adapt** `standards-review.md`: set your base branch, your build/test gate,
   and the project-specific ADR/PDR/WDR checklist.
7. **Configure the repo:** run `scripts/setup-repo.sh` to apply the branch/merge policy
   (merge methods, auto-delete, branch-protection rulesets) and the local hook path —
   the GitHub settings a clone does not inherit.

The records are a starting template you own and adapt — not a runtime dependency.
Vendor and customize; don't submodule.

## Repository setup (`scripts/setup-repo.sh`)

Part of the branch/merge policy (see [WDR 010](docs/engineering/wdr/010-branch-and-merge-flow.md))
lives in GitHub repository settings, which a clone does **not** inherit.
`scripts/setup-repo.sh` re-applies it as config-as-code, so a freshly created or cloned
repo reproduces the policy in one command. It is idempotent — safe to re-run.

**Prerequisite:** the [GitHub CLI](https://cli.github.com) (`gh`), authenticated with
admin on the target repo.

```bash
# configure the current repo (resolved from its 'origin' remote)
scripts/setup-repo.sh

# ...or target a specific repo
scripts/setup-repo.sh owner/repo
```

### What it applies — and what your account type limits

| Setting | Free **public** | Paid (Pro/Team/Enterprise) | Free **private** |
| ------- | :-------------: | :------------------------: | :--------------: |
| Merge methods — squash + merge on, rebase off, squash uses PR title/body | yes | yes | yes |
| Auto-delete head branch on merge | yes | yes | yes |
| Local `pre-commit` hook path (`core.hooksPath=.githooks`) | yes | yes | yes |
| Branch-protection **rulesets** — `develop` squash-only + PR, `main` merge-only + PR, block force-push & deletion | yes | yes | **no** |

GitHub **branch protection and rulesets are not available on free _private_ repositories**.
On a free private repo the script applies everything else and **skips the rulesets with a
notice**, leaving the local hook plus the WDR 010 convention to carry the policy. Make the
repo public (free) or move to a paid plan to enable server-side enforcement, then re-run
the script.

## Process & lifecycle

Each module documents its own rules, template, and status lifecycle:

- [ADR process](docs/architecture/adr/ADR_PROCESS.md)
- [PDR process](docs/product/pdr/PDR_PROCESS.md)
- [WDR process](docs/engineering/wdr/WDR_PROCESS.md)

All three share the lifecycle `draft → under_review → accepted → modified →
deprecated/superseded` and the cardinal rules: **no line numbers, no AI/bot
attribution, no volatile implementation details** — records must stay durable.

## License

[MIT](LICENSE) © Stratovera.
