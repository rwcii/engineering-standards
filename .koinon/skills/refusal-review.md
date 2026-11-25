# Repository facts — refusal-review

## Version
1
## Skill
refusal-review
## Sources
- docs/engineering/review/README.md
- docs/engineering/wdr/005-independent-review-and-control-plane.md

## Verdict format
docs/engineering/review/README.md § Severity and the merge block (the two refusal-lens levels) and
§ Results. The verdict is APPROVE or REQUEST CHANGES, bound to the full head hash, with a table of
the constraints reviewed (file, constraint, kind, source, covers this case) and a table of findings
(severity, file, finding, fix). An empty constraints table is a valid result.
