#!/usr/bin/env bash
# check-promotion-source.sh — a pull request into main must come from this repository's
# develop (WDR 010, Decision 5). Any other base passes. `promotion-source` in CI.
#
# Usage: scripts/check-promotion-source.sh BASE HEAD_REF HEAD_REPO THIS_REPO
set -u
[ "$#" = 4 ] || { echo "usage: $0 BASE HEAD_REF HEAD_REPO THIS_REPO"; exit 2; }
base="$1" head_ref="$2" head_repo="$3" this_repo="$4"

if [ "$base" != "main" ]; then
  echo "PASS  not a release pull request (base ${base})"
  exit 0
fi
if [ "$head_repo" = "$this_repo" ] && [ "$head_ref" = "develop" ]; then
  echo "PASS  release pull request from ${this_repo}:develop"
  exit 0
fi
echo "FAIL  a pull request into main must come from ${this_repo}:develop, not ${head_repo}:${head_ref}"
exit 1
