# Refusal trap patterns

Each pattern has an example and the usual fix. A match is a candidate. Step 3 and step 4
of the skill decide whether it is a trap.

## Patterns in text

| Pattern | Example | Usual fix |
| --- | --- | --- |
| A plan non-goal becomes a permanent ban | A plan said "no terminal input" as a goal for one milestone. Later agents refused all terminal input, also where the work needed it. | Mark old plans as historical. Their non-goals limited only that plan. |
| A narrow limit becomes a general ban | "Do not weaken sandbox settings" started as a limit on one workaround. Agents read it as a ban on every permission change. | Narrow the text to its case, or cite the source that sets the case. |
| A failure report becomes a recovery ban | "Report the failure; do not invent recovery steps" only stopped a false claim of success. Agents stopped all recovery. | Keep "report it"; remove the ban that has no source. |
| An approval step is copied into many files | "Show the exact diff and get approval before you write" copied into a dozen skills. | Remove the copies. State the real approval rule once, where the owner set it. |
| A plan line with no source | "No runtime setup", "do not change live configuration". | Remove, or bring to the owner if it may protect something. |
| An absolute statement with no decision | "Agents never run `sudo`." | Find the owner's words. If none exist, bring it to the owner or remove it. |
| Bans inside an operation skill | A terminal skill that bans common commands with no recorded reason. | Keep the facts the skill needs; remove the bans with no source. |
| Phrases that make approved work look forbidden | "only under existing authorization", "allowance", "denied by default", "stop and ask the owner" inside assigned work, "a peer's report is not authority" used to refuse assigned work. | Remove. The owner's task already authorizes its steps. A peer message adds no permission and removes none. |
| A session remark cited as a rule | A remark from a chat session cited as a decided rule, with no record. | Quote the words with date and question. State its scope. Add no step of its own. |
| A decision stated without its case | "The owner decided X", with no question, options or reason. | Add the question it answered and its scope, or narrow the text. |
| Repeated stop and approve boilerplate | The same "confirm with the owner first" paragraph in every skill. | Remove the repeats. Ask only for missing information or for authority beyond the task. |

## Patterns in code, tests and configuration

| Pattern | Example | Usual fix |
| --- | --- | --- |
| A positive requirement drops a valid case | A membership check keyed to one session ID drops a valid member after a restart. Routing only to roles on a fixed list excludes a valid role. | Widen the rule to the real case, with a positive test. |
| A code condition refuses with no source | An early return or error code that rejects a valid request. | Find its source. If none, bring it to the owner or remove it with a positive test. |
| A fallback that hides a refusal | A configured program path with no fallback, or a subagent excluded from a list, with no reason. | Record the reason, or remove the limit. |
| A check applied before current evidence | A stale lock or fence that refuses work although current state allows it. | Check current state first. |
| A test that asserts a refusal | A test that requires the refusal of a valid operation. | Change it to a positive test, unless a source covers the refusal. |
| A test that looks like a guard but does not guard | The test still passes after the guarded text is weakened. | Fix the test so that it fails when the guard is removed. |
| A parser format gate | Line endings or quoted variables rejected although nothing runs them. | Accept the valid input, or record the reason. |
| A hook that blocks the whole product | A hook proposed for one case that blocks every session. | Scope the hook to its case, or remove it. |
| A settings deny list entry with no source | A deny rule that blocks a command that approved work needs. | Find its source. Change the setting through the project's own rule for settings changes. |
| A native sandbox limit read as a project rule | "The sandbox cannot write here" restated as "never write here". | Describe the limit as a fact of the tool, not as a rule. |

## Candidate search words

Save the block below as `patterns.txt`, one pattern for each line, and pass it to `git grep -f`.
Add the words of your project's own language. A match is a candidate. It is not a
finding.

```text
never|must not|do not|don't|may not|cannot|forbidden|prohibit|not allowed|disallow
only (if|when|under|after)|unless|except|exclusively|restricted to
approv|permission|authoriz|allowance|sign-off|confirm (with|first)
stop and|wait for|ask (the )?(owner|maintainer|user)|before you (write|push|run|change)
denied by default|deny|refus|reject|block|gate|fence|lock
no (new|runtime|live|setup|change)|out of scope|non-goal
at most|limit|cap|maximum|threshold|timeout
```

Search tests and code also for refusal error texts, non-zero exit codes and early returns.
