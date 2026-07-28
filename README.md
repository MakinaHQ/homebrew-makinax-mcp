# makinaX Agent Kit — Homebrew tap

Prebuilt binaries for the **makinaX Agent Kit** (`makinax-mcp`), an MCP server
that gives AI agents governed access to a Gnosis Safe running a
`MakinaLiteModule` strategy.

This repository contains **no source** — only the Homebrew formulas and the
release artifacts they point at.

## Install

```sh
brew tap MakinaHQ/makinax
brew install makinax-mcp
```

Reporting only, with signing code compiled out rather than disabled:

```sh
brew install makinax-mcp-readonly
```

The two conflict — they install the same binary name. Pick one.

```sh
makinax-mcp --version     # variant + version + commit
makinax-mcp init          # writes a minimal config and prints next steps
makinax-mcp --help
```

## Verifying what you downloaded

Every release publishes `SHA256SUMS`, and `BUILD-INFO` naming the source commit
the binaries were built from:

```sh
shasum -a 256 -c SHA256SUMS
```

Homebrew already checks the formula's own `sha256` on install; the above is for
anyone fetching a tarball directly.

## Updating

```sh
makinax-mcp self-update              # latest release
makinax-mcp self-update --tag v0.5.0 # a specific one
makinax-mcp self-update --rollback   # restore the previous binary
```

It downloads from this repository over plain HTTPS — no GitHub account, no
`gh`, no credentials. It verifies the checksum and the staged binary's reported
version before swapping anything, keeps the previous binary as `*.prev`, and
**never compiles**.

## Platforms

macOS arm64 (Apple Silicon) only. No Intel or Linux builds today.

The binaries are **not signed or notarized** yet, so first launch may need
Gatekeeper approval (System Settings → Privacy & Security).

## Scope

Read `docs/RELEASE-0.5.0-scope.md` in the release notes before relying on this:
bridging is built but has never been run end to end, paid packages are blocked
upstream, and no second curator exists. Source access and issue tracking are
internal to MakinaHQ.
