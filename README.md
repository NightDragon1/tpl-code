<p align="center">
  <a href="https://github.com/__OWNER__/__PROJEKT__/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/__OWNER__/__PROJEKT__/actions/workflows/ci.yml/badge.svg?branch=main"></a>
  <a href="https://github.com/__OWNER__/__PROJEKT__/releases"><img alt="Release" src="https://img.shields.io/github/v/release/__OWNER__/__PROJEKT__"></a>
  <a href="https://hub.docker.com/r/__DOCKERHUB_NS__/__PROJEKT__"><img alt="Docker pulls" src="https://img.shields.io/docker/pulls/__DOCKERHUB_NS__/__PROJEKT__"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/github/license/__OWNER__/__PROJEKT__"></a>
  <img alt="Platforms" src="https://img.shields.io/badge/platforms-amd64%20%7C%20arm64-blue">
</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.svg">
    <img alt="<Product name> logo" src="assets/logo-light.svg" width="160">
  </picture>
</p>

# <Full product name>

<2-3 sentences: what it is, for whom, what makes it special.>

Run it only <where it may run, e.g. in a LAN or behind a VPN>. <Who terminates TLS, e.g. a
reverse proxy.> <What is never exposed, e.g. the Docker socket.>

## Architecture

![<Detailed alt text: every part, what it talks to and over which protocol.>](assets/architecture.svg)

## Quick start

Images: `ghcr.io/__OWNER_LC__/__PROJEKT__` and `docker.io/__DOCKERHUB_NS__/__PROJEKT__`.
Tags: `1` (newest 1.x) and the exact version such as `<X.Y>`; there is no `latest`.

### A: docker run

```sh
docker run -d --name __PROJEKT__ --restart unless-stopped \
  --read-only --cap-drop ALL --security-opt no-new-privileges \
  --memory <limit> --pids-limit <limit> \
  -p 127.0.0.1:<port>:<port> \
  -v __PROJEKT__-data:/data \
  ghcr.io/__OWNER_LC__/__PROJEKT__:<X.Y>
```

### B: Docker Compose

```yaml
services:
  __PROJEKT__:
    image: ghcr.io/__OWNER_LC__/__PROJEKT__:<X.Y>
    restart: unless-stopped
    read_only: true
    cap_drop: [ALL]
    security_opt: [no-new-privileges:true]
    mem_limit: <limit>
    pids_limit: <limit>
    ports: ["127.0.0.1:<port>:<port>"]
    volumes: [data:/data]
volumes:
  data:
```

<Ready-made Compose files: relative link to the directory in this repository.>

## First steps

1. <Open the web interface or run the first command.>
2. <Sign in, e.g. with the initial password from the log.>
3. <Change the password.>
4. <Create the first object, up to the first real use.>

## Important variables

| Variable | Default | Purpose |
|---|---|---|
| `<NAME>` | `<value>` | <purpose> |

<One table per part, only the 4-8 most important variables.> All variables:
[Configuration](https://github.com/__OWNER__/__PROJEKT__/wiki/Configuration).

## Links

- [Wiki](https://github.com/__OWNER__/__PROJEKT__/wiki): <keywords, e.g. installation, reverse proxy, things to note, configuration>
- [CHANGELOG](CHANGELOG.md)
- [Releases](https://github.com/__OWNER__/__PROJEKT__/releases)
- [Security policy](SECURITY.md)

## Development

Requirements: <tools with versions, e.g. Go 1.x, Node.js xx, Docker with Buildx>.

| Command | Does |
|---|---|
| `make build` | Builds <what> |
| `make lint` | Runs the linters |
| `make test` | Tests of the changed packages |
| `make test-all` | All tests |
| `make acceptance` | Checks the checksums, then runs the acceptance tests |
| `make e2e` | End-to-end tests |
| `make audit` | Vulnerability scan of the dependencies |
| `make image` | Builds the image for the local platform |

<Build specifics in a few sentences.>

## License

[<License name>](LICENSE) (`__SPDX__`). <What else it covers, e.g. images and documentation.>
