#!/usr/bin/env bash
# Basic health check for the repository README.
set -u
fail=0

if [ ! -f README.md ]; then
  echo "FAIL: README.md does not exist"
  fail=1
else
  echo "PASS: README.md exists"
fi

# the-verdict.txt is Edith Wharton's "The Verdict", not a story by Edgar Allan Poe.
if grep -q -i "Poe" README.md; then
  echo "FAIL: README.md misattributes the corpus to Edgar Allan Poe"
  fail=1
else
  echo "PASS: README.md does not misattribute the corpus"
fi

if grep -q -i "Wharton" README.md; then
  echo "PASS: README.md credits Edith Wharton"
else
  echo "FAIL: README.md does not credit Edith Wharton as the corpus author"
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "1 check(s) failed"
  exit 1
fi
echo "all checks passed"
