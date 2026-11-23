# __PROJEKT__

<One line, at most 100 characters: dockerhub-describe.sh uses it as the short description.>

<One paragraph: what the image does.>

## Security

<Short security note, e.g. where it may be reachable from.> Report vulnerabilities as described in
[SECURITY.md](https://github.com/__OWNER__/__PROJEKT__/blob/main/SECURITY.md).

## Tags

Tags: `1` and the exact version such as `{version}`; no `latest`.
Images are signed with cosign; see [Verifying images](https://github.com/__OWNER__/__PROJEKT__/blob/main/SECURITY.md#verifying-images).

## Quick start

```sh
docker run --rm docker.io/__DOCKERHUB_NS__/__PROJEKT__:{version}
```

```yaml
services:
  __PROJEKT__:
    image: docker.io/__DOCKERHUB_NS__/__PROJEKT__:{version}
    restart: unless-stopped
```

## Variables

| Variable | Default | Meaning |
|---|---|---|
| <NAME> | <value> | <meaning> |

## Links

- Repository: https://github.com/__OWNER__/__PROJEKT__
- Documentation: https://github.com/__OWNER__/__PROJEKT__/tree/main/docs
- Releases: https://github.com/__OWNER__/__PROJEKT__/releases
