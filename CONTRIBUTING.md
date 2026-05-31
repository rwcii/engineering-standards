# Contributing

Thanks for your interest in **Engineering Standards**. There are two ways to use and
improve this kit — pick the one that fits. The policy behind this document is recorded
in [WDR 011](docs/engineering/wdr/011-contribution-and-attestation.md).

## 1. Fork and extend (encouraged)

This repository is MIT-licensed and a **GitHub template**, so the simplest path is to
make it your own — no permission or coordination needed, and the right choice for most
adopters:

- Click **Use this template** (or `gh repo create <your-repo> --template rwcii/engineering-standards`), or fork it.
- Run `scripts/setup-repo.sh` to apply the branch/merge settings (see the README
  [Repository setup](README.md#repository-setup-scriptssetup-reposh)).
- Keep ADR 001.x as-is, fill the templates, add your own records, and adapt anything
  else. It's yours.

## 2. Contribute back to the canonical kit (maintainer-curated)

Changes to *this* repository are curated, to keep the standard set coherent for everyone
who vendors it:

- **Open an issue or discussion first**, describing the change and the decision behind
  it. Pull requests are accepted **by invitation**, once there is agreement — please
  don't open large unsolicited PRs.
- **Follow the branch & merge flow** ([WDR 010](docs/engineering/wdr/010-branch-and-merge-flow.md)):
  branch off `develop`, keep the change scoped (no drive-by edits), and target `develop`
  with a **squash** PR. `develop` is promoted to `main` by the maintainer.
- **Run the preflight:** `standards-review` against `develop` — it must pass (see
  [`.claude/commands/standards-review.md`](.claude/commands/standards-review.md)).
- **Records follow their process docs** (`ADR_PROCESS.md` / `PDR_PROCESS.md` /
  `WDR_PROCESS.md`) and the cardinal rules: no AI/bot attribution, no line numbers or
  volatile details, and every record is a *decision with genuine alternatives*. Use the
  three-question test to pick ADR vs PDR vs WDR.
- **Commits are signed and carry a DCO sign-off** (below).

## Developer Certificate of Origin (DCO)

Every commit merged into the canonical kit must be **signed off**, certifying that you
have the right to submit it under the project's MIT license. Add the sign-off with:

```bash
git commit -s -m "your message"
```

That appends a `Signed-off-by: Your Name <you@example.com>` line using your real name and
email. By signing off you agree to the Developer Certificate of Origin 1.1
(<https://developercertificate.org/>), reproduced here:

```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.


Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

The sign-off is a statement by a **named human** — consistent with this repo's
no-AI/bot-attribution rule and the accountability principle in
[WDR 009](docs/engineering/wdr/009-ai-provenance-and-accountability.md). A human owns and
vouches for every accepted change, even when it was AI-assisted.
