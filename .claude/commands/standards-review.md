# Standards Review — Preflight Check

Perform a comprehensive architecture, product, and code review of all changes on the
current branch compared to the base branch. This review is a preflight gate before
push/PR.

**This review MUST be performed by a separate agent** with no prior context from the
working conversation. Spawn it via the Agent tool so it gives an independent assessment.
The agent must follow every instruction below exactly.

> **Adopting this command:** this is a stack-agnostic skeleton. Set your base branch
> default below, point the test/build references at your project's gate (recorded in ADR
> 002.x), and — optionally — add a project-specific ADR/PDR/WDR checklist table to Phase 2.
> The mandatory protocol and the phase structure are universal; the concrete checks come
> from the project's own decision records.

## Arguments

- `$ARGUMENTS` — optional: base branch override (defaults to `develop`)

## Agent Instructions

The review agent receives the full instructions below. Do NOT summarize or abbreviate them.

---

### MANDATORY REVIEW PROTOCOL — READ THIS FIRST

These rules override everything else. Violation of any rule invalidates the entire review.

1. **READ THE ACTUAL CODE.** You must `Read` every changed file in full before making
   any assessment. If you have not read a file, you may not comment on it, reference it,
   or include it in findings. Skimming grep output or file listings is not reading.

2. **TRACE CODE PATHS END TO END.** Do not assume functionality is wired because a
   function or file appears in the repo. Follow every call chain from entry point to
   execution. A function that exists but is never called is dead code. A route that
   exists but is not mounted is unreachable. Verify by reading the actual wiring code.

3. **DO NOT REASON AGAINST ASSUMPTIONS.** If you haven't verified something by reading
   the code, you don't know it. "This is probably called by…" is not acceptable. "I
   verified this is called from <file>" is.

4. **PATTERN-MATCHING AND INFERENCE IS NOT A SUBSTITUTE FOR READING.** Running a search
   to find a symbol and concluding "it's used" without reading the surrounding code is
   inference. Read the actual call site, understand the context, verify the wiring.

5. **VALIDATE ALL TEST LAYERS.** Every change should have appropriate unit, integration,
   end-to-end, and CI coverage to validate the code and protect against regressions.
   Missing coverage at a layer that matters is a finding — not something to note and move on.

6. **LOOK FOR DEAD CODE AND MISSED CONTENT.** Functions defined but never called, routes
   not mounted, imports unused, configuration added but not referenced, tests that don't
   assert anything meaningful. These are findings.

7. **SILENT DISCARD OR DEFERRAL IS UNACCEPTABLE.** Every issue found must be reported. If
   you discover something and choose not to report it, you have failed the review.

---

### Phase 0: Establish Scope

```bash
BASE_BRANCH="${ARGUMENTS:-develop}"
git diff $(git merge-base HEAD $BASE_BRANCH)...HEAD --stat
git diff $(git merge-base HEAD $BASE_BRANCH)...HEAD --name-only
git log $(git merge-base HEAD $BASE_BRANCH)...HEAD --oneline
```

1. Run the commands above to identify all changed files and commits.
2. **Read EVERY changed file completely** with the Read tool — not grep, not search.
3. Identify the **applicable records**: read the ADR, PDR, and WDR indexes (each
   module's `README.md`) and select the records whose scope the change touches — by tag,
   area, and change type — then deep-read the selected records in full (per WDR 002). You
   need not read the entire corpus, but you must not miss an applicable record; when in
   doubt, include it.
4. Always treat as applicable regardless of the change: ADR 001.x (code architecture)
   and the WDRs governing how work is produced (operating loop, verification, independent
   review, autonomy, agentic security, provenance) — these bear on essentially every
   change.
5. For each changed file, also read the files it imports from or exports to, so you
   understand the full call chain.

---

### Phase 1: Validate the Five Code Architecture Standards

For each standard (ADR 001 and point versions 001.1–001.5), check all changed code and
report pass/fail with file-path evidence. Judge against the project's **enforcement**
realization of each standard (recorded in ADR 002.x), not a fixed toolchain.

- **DRY (001.1):** Duplicated logic, constants, or rules across the changes? Is shared
  logic imported from its canonical home rather than reimplemented? Are derived artifacts
  generated rather than hand-duplicated?
- **Modular (001.2):** Are unit boundaries clean? Does any unit reach into another's
  internals? Do dependencies flow one direction, without cycles?
- **Extensible (001.3):** Can new variants be added without modifying existing dispatch?
  Any new hardcoded switch/if-else on a known type set that should be a registry?
- **Interface Boundaries (001.4):** Do units depend on contracts, not internals? Is data
  access behind its boundary rather than spread through the app? Are units testable in
  isolation?
- **Centralized Config (001.5):** Hardcoded URLs, secrets, or magic numbers that belong
  in config? Direct environment access outside the canonical config source? On a config
  refactor: enumerate settings consumed by the old code (via `git show`) and confirm the
  new code still consumes each — flag any silently dropped setting as **critical**.

---

### Phase 2: Validate ADR Compliance

Read each ADR in `docs/architecture/adr/` and check whether the changes comply with or
violate its decisions. For each accepted ADR, verify the change honors its decisions and
enforcement; for each draft ADR, check consistency with its stated intent.

> Projects may add a checklist table here mapping their key ADRs (007+) to the specific
> things to verify, so reviewers don't have to re-derive them each time.

---

### Phase 2b: Validate PDR Compliance

Read each PDR in `docs/product/pdr/` and check whether the changes comply with its
product decisions. PDRs define **how the product should behave** — user flows and UX
contracts — as distinct from ADRs.

For each accepted PDR, check:

- Does the change modify behavior covered by a PDR? If so, does it comply?
- Does the change introduce new product behavior that should be covered by an existing or
  new PDR?
- Are flow states, transitions, or UX contracts altered without updating the PDR?

If no accepted PDRs exist yet (all draft), note this and check only for consistency with
draft PDR intent.

---

### Phase 2c: Validate WDR Compliance

Read the applicable WDRs in `docs/engineering/wdr/` and check whether the change — and
the way it was produced — complies. WDRs govern **how the work is done**:

- **Operating loop & verification (WDR 003/004):** is there evidence the change was run,
  not just asserted? Are tests honest — nothing skipped, weakened, or made tautological to
  reach green? Does a defect fix carry a regression test seen to fail first? Is the change
  scoped, or does it sprawl into unrequested edits?
- **Independent review & the control plane (WDR 005):** apply **heightened scrutiny to any
  change to the control plane** — the records, CI guards, hooks, `standards-review` itself,
  or enforcement config. A weakened, disabled, or removed check is a **high-severity,
  must-justify** finding, and a gate must not be loosened in the same change whose
  violations it would catch.
- **Autonomy, security, provenance (WDR 006/007/009):** are the autonomy/guardrail,
  prompt-injection-isolation, dependency-trust, and secrets constraints respected? For an
  autonomous change, is the authorizing principal recorded?

For each applicable WDR, report compliant / violation / N/A with file-path evidence.

---

### Phase 3: Data & Security Model Compliance

Validate against the project's data-handling and security records (ADR 004, and ADR
005/006 if accepted):

- Is data access confined to its boundary (no ad-hoc datastore access outside the data layer)?
- Are constrained values enforced at the data layer, and inputs normalized at the boundary?
- Are secrets kept out of source and read from the canonical config source?
- Is all external input validated? Are authn/authz boundaries (if any) respected and fail-closed?

If a record is still a draft stub, check consistency with its stated intent and flag
material gaps.

---

### Phase 4: Trace Code Paths End-to-End

**Do NOT assume functionality is wired because it appears in the repo.** Verify by
reading the wiring — not by searching for the symbol name. For each item, READ the source
and destination files and report the exact location where the wiring occurs, or flag it
as unwired:

- **New public functions:** read the definition, then every file that should call it. Is it actually called?
- **New routes/handlers:** read the route registration. Is the route mounted? Is the middleware order correct?
- **New data operations:** does the query match the actual schema? Are column names correct?
- **New API endpoints:** does the endpoint exist in the contract/spec? Do request/response shapes match? Is generated code in sync?
- **New registry/variant entries:** is the new variant actually registered?
- **New config/env vars:** are they parsed in the canonical config source, with defaults, and documented in the example env file?
- **Refactored functions:** read the OLD implementation from the base branch (`git show $BASE_BRANCH:path`). Enumerate every input case it handled and verify the new code handles each. A lost case is a finding even if the new code "works" for its own logic.

---

### Phase 5: Test Coverage Validation

Verify changes include appropriate tests at the layers that matter:

- **Unit:** do new functions have unit tests covering edge cases?
- **Integration:** do new data operations have integration tests against a real datastore (not mocks for security/data boundaries)?
- **E2E:** do new user-facing flows have end-to-end coverage?
- **CI:** will the project's pre-merge gate catch regressions?
- **Adversarial** (for security/data-critical paths): verify tests exist for the applicable categories below; missing adversarial coverage is a finding.
  - **Auth boundary** (if applicable): invalid/expired/forged credentials, missing or malformed auth headers, wrong-scope access, fail-closed behavior.
  - **Authorization** (if applicable): acting without a grant, acting as the wrong principal, cross-tenant access.
  - **Data integrity:** null/invalid foreign keys, negative/zero where positive is required, NaN/Infinity for numerics, empty strings where non-empty is expected.
  - **Input validation:** oversized payloads, missing required fields, injection patterns in string inputs, unsafe content stored and rendered back.
  - **Rate/quota** (if applicable): exactly-at-limit, one-over-limit, and negative values.

---

### Phase 6: Dead Code & Cleanup

- Functions defined but never called; unused imports; unreachable branches
- Commented-out code that should be removed
- Configuration added but not referenced
- Files created but not reachable from any entry point

---

### Phase 7: Documentation Impact

- Do changes need updates to project docs?
- Do changes require ADR updates or a new ADR?
- Do changes affect product behavior documented in a PDR — or that should be?
- Are README.md / AGENTS.md files in affected modules still accurate?

---

### Phase 8: Deferred & Declined Items

- Were any findings deferred or declined during development?
- Did you notice issues not reported while reading the code?
- **Silent discard or deferral is unacceptable.** Track anything deferred (e.g., as an
  issue with a verbose description: why it's a problem, how to address it, options +
  recommendation), and record the tracking reference here.
- If the Deferred Items table is empty, re-read every finding rated "low" or "note" and
  verify nothing was soft-deferred without tracking.

---

### Phase 9: Self-Audit

Before finalizing:

- Re-read every finding rated "low" or "note" — should any be higher?
- For each function accepting external input: did you verify adversarial coverage?
- For each refactored function: did you compare old vs. new behavior case-by-case via `git show`?
- For each setting consumed by old code: is it still consumed by new code, same name?
- For each test file: does it test failure paths, not just happy paths?
- Is your Deferred Items table truly empty, or did you soft-defer something?

---

## Severity & Review Scope

Per WDR 005, the merge gate has a defined severity scale; classify every finding on it:

| Severity | Meaning                                                                                          | Blocks merge? |
| -------- | ------------------------------------------------------------------------------------------------ | ------------- |
| critical | Breaks correctness, security, or data integrity; or a control-plane check was weakened/disabled  | Yes           |
| high     | A real defect, or a violation of an accepted record, likely to cause harm                        | Yes           |
| medium   | A genuine issue that should be fixed but is contained                                            | No (track)    |
| low      | A minor issue or smell                                                                           | No            |
| note     | An observation, not a defect                                                                     | No            |

Scope the review to **correctness, requirements, and record compliance**. Do not pad the
findings with speculative or stylistic nits — a reviewer that manufactures findings drives
over-engineering. Report every in-scope issue you find (one below the blocking threshold is
recorded, not a blocker) and never silently discard one.

---

## Output Format

The review agent MUST output this structured report:

```
## Scope
- Branch: [branch name]
- Base: [base branch]
- Files changed: N
- Commits: N

## Architecture Standards
| Standard | Status | Evidence |
|----------|--------|----------|
| DRY (001.1) | pass/fail | [file references] |
| Modular (001.2) | pass/fail | [file references] |
| Extensible (001.3) | pass/fail | [file references] |
| Interface Boundaries (001.4) | pass/fail | [file references] |
| Centralized Config (001.5) | pass/fail | [file references] |

## ADR Compliance
| ADR | Status | Evidence |
|-----|--------|----------|
| [each applicable ADR] | compliant/violation/N/A | ... |

## PDR Compliance
| PDR | Status | Evidence |
|-----|--------|----------|
| [each applicable PDR] | compliant/violation/N/A | ... |

## WDR Compliance
| WDR | Status | Evidence |
|-----|--------|----------|
| [each applicable WDR] | compliant/violation/N/A | ... |

## Data & Security Model Compliance
| Check | Status | Evidence |
|-------|--------|----------|
| [each applicable check] | pass/fail | ... |

## Code Path Validation
| Path | Status | Evidence |
|------|--------|----------|
| [each new function/route/query traced] | wired/dead/incomplete | ... |

## Test Coverage
| Layer | Status | Evidence |
|-------|--------|----------|
| Unit | adequate/gaps | ... |
| Integration | adequate/gaps | ... |
| E2E | adequate/gaps | ... |
| Adversarial | adequate/gaps | ... |
| CI | adequate/gaps | ... |

## Findings
| # | Severity | File | Description | Recommended Fix |
|---|----------|------|-------------|-----------------|
| 1 | critical/high/medium/low/note | ... | ... | ... |

## Documentation Impact
- [ ] docs updates needed: [list or "none"]
- [ ] ADR updates needed: [list or "none"]
- [ ] PDR updates needed: [list or "none"]
- [ ] README/AGENTS updates needed: [list or "none"]

## Deferred / Tracked Items
| # | Issue | Tracked? | Reference |
|---|-------|----------|-----------|
| 1 | ... | yes/no | ... |

## Summary
- Total findings: N (X critical, Y high, Z medium)
- Test coverage: [assessment]
- Architecture compliance: [assessment]
- Product compliance: [assessment]
- Recommendation: APPROVE / REQUEST CHANGES / BLOCK
```

**Do NOT approve if there are any critical or high findings.** Be thorough — the cost of
missing a bug in production is higher than the cost of a false positive in review.
