#!/usr/bin/env bash

source test/setup

use Test::More

if ! command -v shellcheck >/dev/null; then
  plan skip_all "The 'shellcheck' utility is not installed"
fi
if [[ ! $(shellcheck --version) =~ 0\.7\.1 ]]; then
  plan skip_all "This test wants shellcheck version 0.7.1"
fi

IFS=$'\n' read -d '' -r -a shell_files <<< "$(
  echo test/setup
  find lib -type f
  find test -name '*.t'
)" || true

skips=(
  # We want to keep these 2 here always:
  SC1090  # Can't follow non-constant source. Use a directive to specify location.
  SC1091  # Not following: bash+ was not specified as input (see shellcheck -x).
  # Items that can be fixed one by one
  SC2086  # Double quote to prevent globbing and word splitting.
  SC2034  # Test__More_VERSION appears unused. Verify use (or export if used externally).
  SC2086  # Double quote to prevent globbing and word splitting.
  SC2015  # Note that A && B || C is not if-then-else. C may run when A is true.
  SC2076  # Don't quote right-hand side of =~, it'll match literally rather than as a regex
  SC2050  # This expression is constant. Did you forget the $ on a variable?
)

skip=$(IFS=,; echo "${skips[*]}")

for file in "${shell_files[@]}"; do
  [[ $file == *swp ]] && continue
  is "$(shellcheck -e "$skip" "$file")" "" \
    "The shell file '$file' passes shellcheck"
done

done_testing

# vim: set ft=sh:
