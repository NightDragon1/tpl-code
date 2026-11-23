#!/usr/bin/env bash
# SPDX-FileCopyrightText: __JAHR__ __OWNER__
# SPDX-License-Identifier: __SPDX__
#
# Sets the short description and overview on Docker Hub. Needs HUB
# (docker.io/<namespace>/<name>), DOCKERHUB_USERNAME and DOCKERHUB_TOKEN.
# The short description is the first line of deploy/dockerhub/overview.md
# that is neither empty nor a heading; {version} is replaced. Login and
# bearer token go through stdin and private files only, never through
# arguments or the log. All texts are checked before Docker Hub is called.
set -euo pipefail
cd "$(dirname "$0")/.."
[ $# -eq 1 ] || { echo "usage: dockerhub-describe.sh VERSION" >&2; exit 2; }
version=$1
[[ "$version" =~ ^[0-9]+\.[0-9]+(-rc[0-9]+)?$ ]] || { echo "::error::invalid version: $version"; exit 2; }
: "${HUB:?HUB is not set}"
repo=${HUB#docker.io/}
full=$(sed "s/{version}/$version/g" deploy/dockerhub/overview.md)
[ -n "$full" ] || { echo "::error::empty overview"; exit 1; }
[ "$(printf '%s' "$full" | wc -m)" -le 25000 ] || { echo "::error::overview over 25000 characters"; exit 1; }
short=$(printf '%s\n' "$full" | grep -vE '^(#|[[:space:]]*$)' | head -n 1)
[ -n "$short" ] || { echo "::error::no short description in the overview"; exit 1; }
[ "$(printf '%s' "$short" | wc -m)" -le 100 ] || { echo "::error::short description over 100 characters"; exit 1; }
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
