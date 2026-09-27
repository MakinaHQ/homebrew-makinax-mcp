<!-- The public tap's README. The source of truth is this file in the source
     repository; release.yml copies it to the tap on stable tags, next to the
     formulas. It carries no version, sha256 or tag, so nothing substitutes
     into it. -->

# makinax-mcp: Homebrew tap

Prebuilt binaries for **makinax-mcp**, an MCP server for operating an existing
makinaX module: read its state and events, build and prove operator calls,
simulate them, send them (read-write build only), and encode owner calls for
the Safe owners.

This repository contains no source, only the Homebrew formulas and the release
artifacts they point at.

## Install

```sh
brew install makinahq/makinax-mcp/makinax-mcp
```

Read-only, with signing code compiled out rather than switched off:

```sh
brew install makinahq/makinax-mcp/makinax-mcp-readonly
```

The two conflict because they install the same command name. Pick one.

## First run

```sh
makinax-mcp --version   # version, commit and variant
makinax-mcp tools       # the tool list as JSON
```

Write a config at `~/.config/makinax/config.toml` (or pass `--config <path>`),
then register the server with your MCP host:

```json
{ "mcpServers": { "makinax": { "command": "makinax-mcp" } } }
```

The agent skill is installed at `$(brew --prefix)/share/<formula>/skills/makinax/SKILL.md`,
where `<formula>` is `makinax-mcp` or `makinax-mcp-readonly`; `brew info` prints the path.

## Verifying what you downloaded

Every release publishes `SHA256SUMS`, and `BUILD-INFO` naming the source
commit the binaries were built from:

```sh
shasum -a 256 -c SHA256SUMS
```

Homebrew checks the formula's own `sha256` on install; the above is for anyone
fetching a tarball directly.

## Platforms

This tap serves macOS arm64 (Apple Silicon).

Linux tarballs (`x86_64-unknown-linux-gnu`) are published with each release
and can be downloaded and unpacked directly. They require glibc 2.39 or newer,
so Ubuntu 22.04 and Debian 12 cannot run them. There is no
`aarch64-unknown-linux-gnu` build. On Linux or Intel macOS the formulas refuse
to install rather than install a binary that cannot run.

The binaries are not signed or notarized, so the first launch on macOS may need
Gatekeeper approval (System Settings, Privacy & Security).
