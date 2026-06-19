<!--
Adopting this kit? This PR template governs PRs to the engineering-standards kit itself.
If you vendored the kit, replace it with your project's own PR checklist — the items below
are a reusable starting point (they map to the WDRs you vendored).

Canonical-kit PRs are maintainer-curated (see CONTRIBUTING.md): please open an issue or discussion
first — PRs are accepted by invitation, once there's agreement. To use the kit for your
own project, fork it or "Use this template" instead (no PR needed).
-->

## What & why

<!-- The change, and the decision behind it. Link the issue/discussion this was invited from. -->

Closes #

## Checklist

- [ ] **Invited** — an issue/discussion exists and there's agreement to proceed (CONTRIBUTING.md)
- [ ] **Branch flow** — branched off `develop`, targets `develop` as a **squash** PR (WDR 010)
- [ ] **Scoped** — no unrelated/drive-by edits (WDR 003)
- [ ] **Preflight** — `standards-review` run against `develop` and passing (WDR 005)
- [ ] **Records** — any ADR/PDR/WDR follows its `*_PROCESS.md` and the cardinal rules (no AI/bot attribution, no line numbers/volatile details, decision-with-alternatives)
- [ ] **Sign-off** — commits are signed and **DCO signed-off** via `git commit -s` (CONTRIBUTING.md / WDR 009)
