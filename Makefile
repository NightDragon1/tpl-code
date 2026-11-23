# SPDX-FileCopyrightText: __JAHR__ __OWNER__
# SPDX-License-Identifier: __SPDX__
#
# Fixed targets: the interface between CI, agent and project. Phase 2b fills
# in the commands per technology; examples in the comments. A target without
# a subject prints one line and exits 0.
.PHONY: build lint test test-all acceptance e2e audit image image-all sbom stubs

build:     ; @echo "build: not configured yet"   # go build ./... | npm run build
lint:      ; @echo "lint: not configured yet"   # golangci-lint run | ruff check .
test:      ; @echo "test: not configured yet"   # go test -race $(PKGS)
test-all:  ; @echo "test-all: not configured yet"   # go test -race ./...
e2e:       ; @echo "e2e: not configured yet"   # npx playwright test
audit:     ; @echo "audit: not configured yet"   # govulncheck ./... && npm audit --omit=dev
image:     ; @echo "image: not configured yet"   # docker build -t __PROJEKT__:test .
image-all: ; @echo "image-all: not configured yet"   # docker buildx build --platform linux/amd64,linux/arm64 -t __PROJEKT__:test .
sbom:      ; @echo "sbom: not configured yet"   # syft __PROJEKT__:test -o spdx-json
stubs:     ; @echo "stubs: not configured yet"   # test that lists open 501 stubs and fails if any remain
acceptance: ; @if [ -s acceptance/SHA256SUMS ]; then sha256sum -c acceptance/SHA256SUMS; fi; echo "acceptance: not configured yet"   # && <acceptance tests>
