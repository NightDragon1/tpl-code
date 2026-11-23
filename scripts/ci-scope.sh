#!/usr/bin/env bash
# SPDX-FileCopyrightText: __JAHR__ __OWNER__
# SPDX-License-Identifier: __SPDX__
#
# Prints true if a pull request touches more than documentation, else false.
# Push to main, tags, nightly and manual runs always run in full. A diff error
# or a missing base runs everything. A documentation file that a test reads
# (README, Docker Hub texts) stays code: do not add it to the pattern.
set -euo pipefail
code=true
if [ "${GITHUB_EVENT_NAME:-}" = pull_request ]; then
  base="origin/${GITHUB_BASE_REF:-main}"
  if changed=$(git diff --name-only "$base"...HEAD 2>/dev/null) && [ -n "$changed" ]; then
    grep -qvE '(\.md$|^docs/|^LICENSE)' <<<"$changed" || code=false
  fi
fi
echo "$code"
