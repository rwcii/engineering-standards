# Repository facts — standards-review

## Version
1
## Skill
standards-review
## Sources
- docs/engineering/review/README.md
- docs/engineering/review/standards-lens.md
- docs/engineering/wdr/005-independent-review-and-control-plane.md

## Review procedure
docs/engineering/review/README.md. Read it in full. It sets when the review runs, the reviewer, the
severity scale, the merge block, the record of results and the recheck.
## Standards lens
docs/engineering/review/standards-lens.md, the instructions of the reviewer.
## Brief fields
The nine fields of docs/engineering/review/README.md § Brief: repository, branch, base and head
hashes; kind (full or recheck, with the recheck inputs); lens; scope; done criteria; deciding
records; author check; gate documents; report location.
## Report location
The full report stays unedited in a local folder outside version control. The verdict, the head
hash and the findings go in the pull request's review summary (docs/engineering/review/README.md
§ Results).
## Independence rule
A fresh context in its own checkout at the head hash, with no history of the authoring work, that
wrote none of the change (WDR 005, Decision 1).
## Gate documents
The list in docs/engineering/review/README.md § Gate documents. A change to one is judged by the
rules at the base commit.
