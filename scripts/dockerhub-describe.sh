#!/usr/bin/env bash
# SPDX-FileCopyrightText: __JAHR__ __OWNER__
# SPDX-License-Identifier: __SPDX__
#
# Sets the short description and overview on Docker Hub. Needs HUB
# (docker.io/<namespace>/<name>), GITHUB_REPOSITORY, DOCKERHUB_USERNAME and
# DOCKERHUB_TOKEN. The overview is deploy/dockerhub/overview.md: each marker
# line is replaced by its part of README.md (security note: the paragraph
# starting with "Run it only"; the sections "## Quick start" and
# "## Important variables"), relative links in these parts become absolute
# (images on raw.githubusercontent.com, other links on blob/main),
# {version} is replaced. The short description is the first line of the
# overview that is not empty, a heading, a badge or image, HTML or a quote.
# --dry-run prints both texts and does not call Docker Hub. Login and bearer
# token go through stdin and private files only, never through arguments or
# the log. All texts are checked before Docker Hub is called.
set -euo pipefail
cd "$(dirname "$0")/.."
dry=false
if [ "${1:-}" = --dry-run ]; then dry=true; shift; fi
[ $# -eq 1 ] || { echo "usage: dockerhub-describe.sh [--dry-run] VERSION" >&2; exit 2; }
version=$1
[[ "$version" =~ ^[0-9]+\.[0-9]+(-rc[0-9]+)?$ ]] || { echo "::error::invalid version: $version"; exit 2; }
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is not set}"
$dry || : "${HUB:?HUB is not set}"

section()  { awk -v h="## $1" '/^## / { on = ($0 == h) } on' README.md; }
security() { awk '/^Run it only/ { on = 1 } on && /^$/ { exit } on' README.md; }
absolute() {
  sed -e "s#!\[\([^]]*\)](\([^):]*\))#![\1](https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main/\2)#g" \
    -e "s#](\([^):]*\))#](https://github.com/${GITHUB_REPOSITORY}/blob/main/\1)#g"
}
part() {
  local text
  if [ "$1" = security ]; then text=$(security); else text=$(section "$1"); fi
  [ -n "$text" ] || { echo "::error::marker not filled: README.md has no part '$1'" >&2; return 1; }
  printf '%s\n' "$text" | absolute
}

full=$(while IFS= read -r line || [ -n "$line" ]; do
  case $line in
    "<!-- security note of README.md -->")       part security || exit 1 ;;
    "<!-- quick start of README.md -->")         part "Quick start" || exit 1 ;;
    "<!-- important variables of README.md -->") part "Important variables" || exit 1 ;;
    *) printf '%s\n' "${line//\{version\}/$version}" ;;
  esac
done < deploy/dockerhub/overview.md) || exit 1

[ -n "$full" ] || { echo "::error::empty overview"; exit 1; }
case $full in *"<!-- "*" of README.md -->"*) echo "::error::marker not filled"; exit 1 ;; esac
relative=$(printf '%s\n' "$full" | grep -oE '\]\([^)]*\)' | grep -v '^](https://' || true)
[ -z "$relative" ] || { echo "::error::relative link in the overview: $(head -n 1 <<<"$relative")"; exit 1; }
[ "$(printf '%s' "$full" | wc -m)" -le 25000 ] || { echo "::error::overview over 25000 characters"; exit 1; }
short=$(printf '%s\n' "$full" | grep -vE '^(#|\[!|!\[|<|>|[[:space:]]*$)' | head -n 1 || true)
[ -n "$short" ] || { echo "::error::no short description in the overview"; exit 1; }
[ "$(printf '%s' "$short" | wc -m)" -le 100 ] || { echo "::error::short description over 100 characters"; exit 1; }
if $dry; then printf '%s\n\n%s\n' "$short" "$full"; exit 0; fi

repo=${HUB#docker.io/}
umask 077
login=$(mktemp); auth=$(mktemp)
trap 'rm -f "$login" "$auth"' EXIT
code=$(jq -n '{identifier: env.DOCKERHUB_USERNAME, secret: env.DOCKERHUB_TOKEN}' |
  curl -sS -o "$login" -w '%{http_code}' --data @- -H 'Content-Type: application/json' \
    https://hub.docker.com/v2/auth/token) || code=000
[ "$code" = 200 ] || { echo "::error::Docker Hub login failed (HTTP $code)"; exit 1; }
jq -er '"Authorization: Bearer " + .access_token' "$login" > "$auth"
code=$(jq -n --arg s "$short" --arg f "$full" '{description: $s, full_description: $f}' |
  curl -sS -o /dev/null -w '%{http_code}' -X PATCH --data @- -H 'Content-Type: application/json' \
    -H @"$auth" "https://hub.docker.com/v2/repositories/$repo/") || code=000
case $code in 2??) echo "description of $repo set" ;; *) echo "::error::HTTP $code"; exit 1 ;; esac
