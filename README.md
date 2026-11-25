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

**Quickest start — use the template.** This is a GitHub
[template repository](https://docs.github.com/articles/creating-a-repository-from-a-template):
click **Use this template** (or `gh repo create <your-repo> --template rwcii/engineering-standards`)
to get a fresh repo with these files, then run `scripts/setup-repo.sh` to apply the GitHub
settings a template does not carry (merge methods, auto-delete, branch-protection rulesets,
hook path). To adopt into an *existing* repo instead, follow the common steps, then the steps of
the way your project holds the records (WDR 002, Decision 4).

**Common steps**

1. **Install the skills** from a shared catalog for your agents — this repository uses
   [Koinon](https://github.com/rwcii/koinon) — and copy `docs/engineering/review/` and
   `.koinon/skills/` into your repo. By default, do not copy the catalog's skill procedures into
   the repo; a project that cannot install the catalog keeps local skills and says so in its
   `AGENTS.md` (WDR 008, Decision 4).
2. **Adapt** the facts in `.koinon/skills/` (your base branch, record folders and check
   commands) and the review documents in `docs/engineering/review/` (your build/test gate, and
   an optional project-specific ADR/PDR/WDR checklist in the standards lens).
3. **Replace** `CONTRIBUTING.md` and `.github/PULL_REQUEST_TEMPLATE.md` with your own —
   they govern contributions to the *kit itself*. The DCO section and the PR checklist
   items are reusable starting points you can keep.
4. **Configure the repo:** run `scripts/setup-repo.sh` to apply the branch/merge policy
   (merge methods, auto-delete, branch-protection rulesets) and the local hook path —
   the GitHub settings a clone does not inherit.

**If you copy the records** — you own and adapt them:

1. **Copy** `docs/architecture/adr/`, `docs/product/pdr/` and `docs/engineering/wdr/` into
   your repo.
2. **Keep** ADR 001.x as-is (the universal code-architecture standards) and the baseline
   WDRs 001–009.
3. **Fill in** the templates for your stack: ADR 002.x (frontend / api /
   backend-persistence) and ADR 004.x (your data-handling specifics).
4. **Flesh out** the stubs (ADR 005 Security, 006 Authentication) when those
   decisions are made — or leave them `draft` until then.
5. **Add** your project's own ADRs from 007+, your PDRs from 001, and your WDRs from 010.
   WDR 010 ships as a branch-flow *template* (the worked example of a project-specific WDR):
   adopt its default flow or replace it with your own.

**If you cite the records from one source** — you follow them and do not edit them:

1. **Pin** a list of the source's records at a known version in your repo, and add a check
   that fails a citation to a record missing from that list. Move the pin only in a reviewed
   change.
2. **Cite** each shared record by its source and ID. Point the standards lens and the record
   facts at the source's record indexes, read at the pinned version.
3. **Keep your own records** only for decisions that are yours. If you keep any, give them
   their own series and index, and set `.koinon/skills/record.md` and
   `.koinon/skills/standards-audit.md` to that series; if you keep none, leave those facts out.
4. **Rewrite the copied facts and review documents** so that every path they name exists in
   your repo: replace each reference to a local record (such as a WDR path in a facts file's
   Sources) with your pinned list or with the source document read at the pin, and remove each
   reference to a facts file you left out (such as the record checks in `check.md`). Then run
   the catalog's state check and confirm that every facts file you kept is valid and every
   Sources path exists. With no own series, the record and standards-audit skills report their
   facts as missing; that is expected, because they have no series of your own to work on until
   you keep your own records (step 3).

Either way, don't hold the records through a live link that follows the source's latest state,
such as a submodule (WDR 002, Decision 4).

## Using Koinon

Koinon connects agent sessions, carries review and decision messages, and supplies shared
skills. A project configures those skills with its own policy and check commands.

### Install the skills

On macOS or Linux with Homebrew, install Koinon and set up Claude Code and Codex:

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
families, installation options and agent-specific locations.

For a machine without Koinon, run the following from the source of Koinon v0.13.0 or later.
Replace the example version with the release you want:

```sh
sh scripts/install-skills.sh v0.13.3
```

The script verifies the release archive and installs the skills at user scope. Steps that
call Koinon tools require the running Koinon service.

### Configure a project

Create `.koinon/skills/NAME.md` for the skills your project uses. Set its `Version`, `Skill` and
`Sources`, then provide the documented facts such as your base branch, check commands and
review procedures. [This repository's facts](.koinon/skills/) are examples. Check them with
`library_state` in your Koinon-connected agent, or use the command-line equivalent:

```sh
koinon library state --scope project --as FAMILY:SESSION_ID
```

Replace `FAMILY:SESSION_ID` with your registered native session identity. Look for
`present-valid` in the repository facts report. Projects that keep local procedures because
they cannot install the catalog record that choice in their `AGENTS.md`. See
[WDR 008](docs/engineering/wdr/008-context-and-memory-engineering.md#5-decision-4-skills-come-from-one-shared-catalog-a-repository-keeps-only-its-facts).

### How this repository uses Koinon

The [task-to-skill table](AGENTS.md#skills) links each task to its installed entry and
project facts. A change moves through the following steps.

1. **Plan and branch.** For a multi-PR deliverable, use `koinon-sprint` to agree on acceptance
   criteria, checks, and the order of increments. Start the work branch from `develop`.
2. **Pair and verify.** The driver edits and commits. The observer receives a frozen checkpoint
   through Koinon's message bridge and sends one batch of reproduced findings. The driver uses
   `koinon-check` to run the project's checks.
3. **Review the candidate.** Independent reviewers use `koinon-standards-review` and
   `koinon-refusal-review` on the same frozen head. Each records a head-bound verdict under the
   [review procedure](docs/engineering/review/README.md).
4. **Publish and merge.** A Koinon decision card carries any approval needed to push and open a
   PR or to merge it. The PR records the review results for that head. The feature lands in
   `develop` as a squash, following [CONTRIBUTING.md](CONTRIBUTING.md) and
   [WDR 010](docs/engineering/wdr/010-branch-and-merge-flow.md).
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
