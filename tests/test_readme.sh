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

if [ "$fail" -ne 0 ]; then
  echo "1 check(s) failed"
  exit 1
fi
echo "all checks passed"
