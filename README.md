# Engineering Standards

A portable, stack-agnostic system of **decision records** and independent **standards review**
and **refusal review** gates. Projects can copy the records or cite them against a pinned list.
This repository uses [Koinon](https://github.com/rwcii/koinon) for its shared agent skills and
coordination.

It has three record types and two review gates:

- **Architecture Decision Records (ADRs)** — *how the system is built*: structure,
  patterns, boundaries, infrastructure. See [`docs/architecture/adr/`](docs/architecture/adr/).
- **Product Decision Records (PDRs)** — *how the product behaves*: user flows,
  UX contracts, voice/identity. See [`docs/product/pdr/`](docs/product/pdr/).
- **Workflow Decision Records (WDRs)** — *how the work is done*: the engineering
  workflow, the agent operating loop, the review/enforcement gates, and the record
  system itself. See [`docs/engineering/wdr/`](docs/engineering/wdr/).

Plus a [review procedure](docs/engineering/review/README.md) with two reviewer lenses — a
[standards lens](docs/engineering/review/standards-lens.md) that checks a branch against the
records, and a [refusal lens](docs/engineering/review/refusal-lens.md) that traces every refusal,
gate or limit a branch adds to a source. The agent skills that run these reviews, write records,
plan sprints and hand off work come from the shared [Koinon](https://github.com/rwcii/koinon)
catalog; this repository keeps only the facts those skills read, in
[`.koinon/skills/`](.koinon/skills/) (WDR 008, Decision 4).

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
│   └── engineering/
│       ├── wdr/              # Workflow Decision Records + process
│       └── review/           # review procedure, standards lens, refusal lens
├── scripts/
│   └── setup-repo.sh         # apply the branch/merge policy to a GitHub repo (WDR 010)
├── .githooks/
│   └── pre-commit            # blocks direct commits to main (WDR 010)
└── .koinon/skills/           # facts the shared Koinon skills read for this repository
```

The skills are not kept in this repository. Agents use the Koinon skills installed on the
machine, and each skill reads this repository's values from its facts file in `.koinon/skills/`
(see the skill table in [AGENTS.md](AGENTS.md)).

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

Start from this [GitHub template](https://docs.github.com/articles/creating-a-repository-from-a-template)
or adopt the kit into an existing checkout. You can own a copy of the records or cite a pinned
set. The [adoption runbook](docs/ADOPTING.md) covers both paths, including repository setup and
verification.

## Using Koinon

Koinon connects agent sessions, carries review and decision messages, and supplies shared
skills. A project configures those skills with its own policy and check commands.

### Import the skills without installing Koinon

Koinon releases from v0.13.0 include a standalone skills archive. No clone or running
daemon is needed to import it. Choose a release tag and download that release's installer.
The example needs a POSIX shell, `curl`, `tar`, `awk` and `sha256sum` or `shasum`.

```sh
version=v0.13.4
curl -fsSLO "https://raw.githubusercontent.com/rwcii/koinon/${version}/scripts/install-skills.sh" &&
  sh install-skills.sh "$version"
```

The script downloads `koinon-skills.tar.gz` and `SHA256SUMS`. It checks the archive
checksum and validates the entries before writing any skill. Set `KOINON_SKILLS_BASE`
to use a release mirror. The installer writes each skill as
`koinon-NAME/SKILL.md` at user scope. The destinations are:

| Agent | Skills directory |
| ----- | ---------------- |
| Claude Code | `$CLAUDE_CONFIG_DIR/skills`, or `~/.claude/skills` |
| Codex | `~/.agents/skills` |
| OpenCode | `${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills`, if the configuration directory exists |
| Antigravity | `~/.gemini/config/skills`, if the configuration directory exists |
| Grok | `${GROK_HOME:-$HOME/.grok}/skills`, if the configuration directory exists |

The installer skips `koinon-guide`, which needs the Koinon binary. Run it again with a new
tag to update the copies. To remove the standalone copies, delete the specific
`koinon-NAME` directories the installer wrote. See the
[skills-only installation guide](https://github.com/rwcii/koinon/blob/main/docs/INSTALL.md#skills-on-a-computer-with-no-koinon)
for details.

With the project facts and usual development tools, you can use the check, record, sprint,
sprint-closeout, standards review and audit, refusal review and audit, peer review, pair,
ship, release and provenance procedures. Any step the project configures to use a Koinon
tool still needs the daemon. To use the shared preflight runner, get
[`scripts/preflight-run.sh`](https://github.com/rwcii/koinon/blob/v0.13.4/scripts/preflight-run.sh)
from the matching release source and supply the lens instructions locally when running
without the binary. Handoff and pickup can use local snapshots, but board
checks are unavailable. Agent messaging, shared work claims and decision cards need the daemon.
Team coordination, recovery and session-management skills also depend on it for their
Koinon-backed steps.

### Install Koinon with its skills

For messaging, work claims and decision cards, install the Koinon runtime. On macOS or
Linux with Homebrew, install Koinon and set up Claude Code and Codex:

```sh
brew install rwcii/koinon/koinon
"$(brew --prefix)/bin/koinon" install --agent claude --agent codex
```

You can also download a [release binary](https://github.com/rwcii/koinon/releases) for your
platform, verify its checksum, and run the same install command with that binary. Use
`koinon setup FAMILY` to configure another supported family after installation. Koinon writes
entries named `koinon-NAME` into the agents' user-level skill directories. See the
[Koinon README](https://github.com/rwcii/koinon) and
[installation guide](https://github.com/rwcii/koinon/blob/main/docs/INSTALL.md) for supported
families and installation options.

### Configure a project

Create `.koinon/skills/NAME.md` for the skills your project uses. Set its `Version`, `Skill` and
`Sources`, then provide the documented facts such as your base branch, check commands and
review procedures. [This repository's facts](.koinon/skills/) are examples. Check them with
`library_state` in your Koinon-connected agent, or use the command-line equivalent:

```sh
koinon library state --scope project --as FAMILY:SESSION_ID
```

Replace `FAMILY:SESSION_ID` with your registered native session identity. Look for
`present-valid` in the repository facts report.

Without Koinon, check the facts manually against the installed skill's
`<!-- koinon:repository-facts -->` schema. Use `Version` 1, the schema's skill name in
`Skill`, and one repository-relative path per bullet in `Sources`. Confirm those paths
exist, include all required headings, and use each declared heading at most once.

Projects that keep local procedures because
they cannot install the catalog record that choice in their `AGENTS.md`. See
[WDR 008](docs/engineering/wdr/008-context-and-memory-engineering.md#5-decision-4-skills-come-from-one-shared-catalog-a-repository-keeps-only-its-facts).

### How this repository uses Koinon

The [task-to-skill table](AGENTS.md#skills) lists this repository's skill entries and their
project facts. The steps below show where Koinon fits in the development flow.

1. **Plan and branch.** For a multi-PR deliverable, use `koinon-sprint` to agree on acceptance
   criteria, checks, and the order of increments. Start the work branch from `develop`.
2. **Build and verify.** Use `koinon-check` to run the project's checks. In paired work,
   `koinon-pair` guides the driver and observer. The driver edits and commits, and the observer
   receives a frozen checkpoint through Koinon's message bridge and sends one batch of
   reproduced findings.
3. **Review the candidate.** Independent reviewers use `koinon-standards-review` and
   `koinon-refusal-review` on the same frozen head. Each records a head-bound verdict under the
   [review procedure](docs/engineering/review/README.md).
4. **Publish and merge.** Follow [CONTRIBUTING.md](CONTRIBUTING.md) and
   [WDR 010](docs/engineering/wdr/010-branch-and-merge-flow.md) for publication and merge.
   When the team asks for approval through Koinon, the decision card names the action and its
   reviewed head. A team working without Koinon uses its project's approval channel.
   The PR records the verdicts for that head, and the feature lands in
   `develop` as a squash.
5. **Resume a session.** `koinon-handoff` writes a private work snapshot. `koinon-pickup` reads
   that snapshot and verifies the current state before resuming.

The catalog also offers `koinon-ship` for project publication workflows and
`koinon-provenance` for projects with usage capture tooling. Their operation depends on the
adopting project's policy, facts and commands. This repository documents its contribution
flow in [CONTRIBUTING.md](CONTRIBUTING.md).

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

## Contributing

Two ways to engage (see [CONTRIBUTING.md](CONTRIBUTING.md)):

- **Fork and extend — encouraged.** It's MIT and a template: **Use this template** or
  fork, run `scripts/setup-repo.sh`, and make it yours. No permission needed.
- **Contribute back — maintainer-curated.** Open an issue first; PRs are by invitation,
  follow the [WDR 010](docs/engineering/wdr/010-branch-and-merge-flow.md) branch flow,
  pass the standards review and the refusal review, and carry signed commits with a
  [DCO](https://developercertificate.org/) sign-off (`git commit -s`).

## License

[MIT](LICENSE) © Stratovera.
