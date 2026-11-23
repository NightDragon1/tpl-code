# Security policy

## Reporting a vulnerability
Please report vulnerabilities privately through GitHub:
[Report a vulnerability](https://github.com/__OWNER__/__PROJEKT__/security/advisories/new)
(Private Vulnerability Reporting). Do not open a public issue, pull request
or discussion for a vulnerability.

Please include the affected component and commit, how to reproduce it,
what an attacker gains, and a proposed fix if you have one.

This project is run in spare time, so there are no fixed response times.
You will get an answer in the advisory, and credit if you wish.

## Supported versions
Only the latest release receives security fixes.

## Scope
<In scope: code in this repository, e.g. ... Out of scope: ...>

## Verifying images
Images on ghcr.io and Docker Hub are signed keyless with cosign (cosign 3 or newer):

    cosign verify ghcr.io/__OWNER_LC__/__PROJEKT__:<version> \
      --certificate-identity-regexp '^https://github\.com/__OWNER__/__PROJEKT__/\.github/workflows/release\.yml@refs/tags/' \
      --certificate-oidc-issuer https://token.actions.githubusercontent.com
