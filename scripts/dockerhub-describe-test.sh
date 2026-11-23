#!/usr/bin/env bash
# SPDX-FileCopyrightText: __JAHR__ __OWNER__
# SPDX-License-Identifier: __SPDX__
#
# Tests dockerhub-describe.sh --dry-run against an example README and
# overview in a temporary directory, then against the files of this
# repository. Never calls Docker Hub.
# Backticks in patterns are literal Markdown.
# shellcheck disable=SC2016
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export GITHUB_REPOSITORY=example/demo
unset HUB DOCKERHUB_USERNAME DOCKERHUB_TOKEN
fails=0

readme() {
  cat <<'EOF'
# Demo

Intro.

Run it only in a LAN. TLS comes from a
[reverse proxy](docs/proxy.md).

This paragraph is not part of the security note.

## Quick start

See [compose](deploy/compose/) and [site](https://example.org).

```sh
docker run demo:1.4
```

## First steps

Not copied.

## Important variables

| Variable | Default | Purpose |
|---|---|---|
| `DEMO_PORT` | `8080` | Port |

## Links
EOF
}

overview() {
  cat <<'EOF'
# Demo panel

[![CI](https://example.org/badge.svg)](https://example.org/ci)

Demo panel – does demo things.
More text.

<!-- security note of README.md -->

Tags: `1` and `{version}`.

<!-- quick start of README.md -->

<!-- important variables of README.md -->
EOF
}

# setup README OVERVIEW: writes an example repository to $tmp/repo.
setup() {
  rm -rf "$tmp/repo"
  mkdir -p "$tmp/repo/scripts" "$tmp/repo/deploy/dockerhub"
  cp "$here/dockerhub-describe.sh" "$tmp/repo/scripts/"
  printf '%s\n' "$1" > "$tmp/repo/README.md"
  printf '%s\n' "$2" > "$tmp/repo/deploy/dockerhub/overview.md"
}

# expect NAME RC PATTERN: runs the script, checks exit code and output.
expect() {
  local out rc=0
  out=$("$tmp/repo/scripts/dockerhub-describe.sh" --dry-run 1.4 2>&1) || rc=$?
  if [ "$rc" != "$2" ] || ! grep -qF -- "$3" <<<"$out"; then
    echo "FAIL $1: exit $rc, want $2 and '$3'"; printf '%s\n' "$out" | sed 's/^/  /'
    fails=$((fails + 1))
  else
    echo "ok   $1"
  fi
}

# refute NAME PATTERN: output of the last good example must not contain PATTERN.
refute() {
  if "$tmp/repo/scripts/dockerhub-describe.sh" --dry-run 1.4 | grep -qF -- "$2"; then
    echo "FAIL $1: output contains '$2'"; fails=$((fails + 1))
  else
    echo "ok   $1"
  fi
}

setup "$(readme)" "$(overview)"
expect short-description 0 $'Demo panel – does demo things.\n\n# Demo panel'
expect security-note 0 $'Run it only in a LAN. TLS comes from a\n[reverse proxy](https://github.com/example/demo/blob/main/docs/proxy.md).'
expect quick-start 0 '## Quick start'
expect relative-link-absolute 0 '[compose](https://github.com/example/demo/blob/main/deploy/compose/)'
expect absolute-link-kept 0 '[site](https://example.org)'
expect variables 0 '| `DEMO_PORT` | `8080` | Port |'
expect version 0 'Tags: `1` and `1.4`.'
refute security-note-one-paragraph 'not part of the security note'
refute section-ends-at-next-heading 'Not copied.'
refute markers-replaced 'of README.md -->'

setup "$(readme | sed 's/^## Quick start$/## Quickstart/')" "$(overview)"
expect missing-section 1 "README.md has no part 'Quick start'"

setup "$(readme | sed 's/^Run it only/Run only/')" "$(overview)"
expect missing-security-note 1 "README.md has no part 'security'"

setup "$(readme)" "$(overview; echo '<!-- quick  start of README.md -->')"
expect unknown-marker 1 'marker not filled'

setup "$(readme)" "$(overview; echo 'See [notes](notes.md).')"
expect relative-link-in-overview 1 'relative link in the overview: ](notes.md)'

setup "$(readme)" "$(overview | sed "s/^Demo panel – .*/$(printf 'x%.0s' {1..101})/")"
expect long-short-description 1 'short description over 100 characters'

setup "$(readme)" "$(overview; head -c 25001 /dev/zero | tr '\0' x)"
expect long-overview 1 'overview over 25000 characters'

setup "$(readme)" "$(overview)"
rc=0; "$tmp/repo/scripts/dockerhub-describe.sh" --dry-run latest >/dev/null 2>&1 || rc=$?
if [ "$rc" = 2 ]; then echo "ok   invalid-version"; else echo "FAIL invalid-version: exit $rc"; fails=$((fails + 1)); fi

if "$here/dockerhub-describe.sh" --dry-run 1.0 >/dev/null; then
  echo "ok   this-repository"
else
  echo "FAIL this-repository"; fails=$((fails + 1))
fi

[ "$fails" = 0 ] || { echo "$fails failed"; exit 1; }
