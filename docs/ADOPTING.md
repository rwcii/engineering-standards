# Adopt Engineering Standards

Use this runbook in the target repository, whether it comes from the template or already has
its own records and workflow. Read the target's instructions and record indexes before
adapting the kit.

1. **Choose how to hold the shared records.** Follow
   [WDR 002, Decision 4](engineering/wdr/002-record-system-as-infrastructure.md#5-decision-4-shared-records-are-copied-or-cited-against-a-pinned-list).
   Copy records when the target will own and adapt them. Use a pinned source and record list
   when the target will cite shared rules. Record the choice and its scope in the target's
   governing workflow document. A pinned citation names the source, record ID, revision and
   applicable section. Avoid a live link that follows upstream changes, such as a submodule
   configured to follow the source's latest state.

   **Verify.** The target records its choice and has no live-tracking link to the shared
   records. For a cited set, the record list identifies an exact upstream revision and the
   citation check rejects an ID missing from that list.

2. **Bring in the records and review documents.** For the copy path, bring in the
   [ADR](architecture/adr/), [PDR](product/pdr/) and [WDR](engineering/wdr/) records
   the target adopts, with their process guides, templates and indexes. Retain the shared
   architecture and workflow baseline. Adapt draft stack and security records when the target makes those
   choices. Treat WDR 010 as an example branch policy. For the cite path, bring in the pinned
   record list and use the process guides for any local series the target maintains.
   Keep the target's existing record identifiers and numbering. Resolve collisions in the
   imported set or use qualified citations. Bring in the [review procedure and lenses](engineering/review/)
   and point them to the target's local indexes or the pinned source.

   **Verify.** An example citation reaches its governing record, and existing target
   record IDs still reach the same decisions. The target has both lenses and can find the
   applicable process guides and indexes.

3. **Get the skills and adapt their facts.** Choose either path in the
   [Using Koinon](../README.md#using-koinon). Start from the relevant [skill facts](../.koinon/skills/)
   and give them the target's base branch, record sources, check commands, review paths,
   and report location. In the cite-only layout, replace local paths that do not exist
   with references to the pinned policy and remove checks that refer to omitted facts.
   Keep record or standards-audit facts when the target has a local series for those
   skills to use.

   **Verify.** The catalog reports the facts as `present-valid`, or a manual comparison
   against each installed schema passes when using the standalone skills. For a cite-only
   target without a local series, missing record and standards-audit facts are expected.
   Each named source path resolves, and each configured check command and report path
   matches the target's policy.

4. **Integrate the agent instructions.** Merge the applicable rules and links into the
   target's `AGENTS.md` and scoped instruction files. Build its task-to-skill table from
   the skills it uses and the facts it maintains. Keep native agent entry files as
   pointers to the owning instructions where the target uses that convention. If the
   target keeps local skill procedures under
   [WDR 008, Decision 4](engineering/wdr/008-context-and-memory-engineering.md#5-decision-4-skills-come-from-one-shared-catalog-a-repository-keeps-only-its-facts),
   record that choice in the target's `AGENTS.md`.

   **Verify.** A reader starting at the target's `AGENTS.md` reaches the right record,
   skill and facts for a representative task. The instructions describe the target's
   actual branches and gates.

5. **Apply the target's branch policy.** Compare the desired policy with the target's
   existing settings and hook configuration. If the target adopts this kit's GitHub flow,
   use [`scripts/setup-repo.sh`](../scripts/setup-repo.sh) from the target checkout,
   together with the matching hook, when the target authorizes those changes. For another
   flow, use the target's setup mechanism. The [repository setup notes](../README.md#repository-setup-scriptssetup-reposh)
   describe the kit script and its GitHub prerequisites.

   **Verify.** Read back the settings and local hook path. Compare merge methods, protected
   branches and branch rules with the target's policy. Record any unavailable enforcement
   as such in the adoption results.

6. **Apply the target's publication rules.** In the review procedure, review facts,
   contribution guide and PR template, point to the target rules for public material.
   Replace references to this repository's private-project-name rule in
   [WDR 007, Decision 4](engineering/wdr/007-agentic-security.md#5-decision-4-public-text-names-no-private-project)
   and its attribution rule in
   [WDR 002, Decision 5](engineering/wdr/002-record-system-as-infrastructure.md#6-decision-5-attribute-decisions-by-name-in-the-owning-record).
   In a copied record set, state which publication decisions the target adopts and update its
   governing records for the rest. A cite-only target leaves the source records in place and
   cites its own publication rules. Keep the target's existing contribution process and adapt
   the relevant checklist items.

   **Verify.** The review and publication checklist points to the target's governing
   rules. A sample public verdict can cite its evidence under those rules.

7. **Name the approval channel.** When the team uses Koinon, say where the project's
   decision cards fit into the existing authorization policy. Without Koinon, name the
   project's approval channel and where it keeps review and approval evidence.

   **Verify.** A contributor can identify where to obtain an approval when the policy
   requires one, and how to match it to the reviewed commit or authorized action.

8. **Run both first reviews.** Freeze a candidate. Check the facts and relative links,
   then run independent standards and refusal reviews through the target's review
   procedure. Record each verdict and resolve findings using that procedure.

   **Verify.** The facts and links pass. Both reports name the same full candidate head
   and its base and show the result of each review.
