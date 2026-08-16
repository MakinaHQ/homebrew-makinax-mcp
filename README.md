<!-- THE PUBLIC TAP'S README. Source of truth is THIS file; the published copy
     at MakinaHQ/homebrew-makinax-mcp/README.md is written by release.yml's
     tap-sync step, on stable tags only.

     It lives here for the same reason the formulas do: "the tap could only
     ever go stale because syncing it was a thing someone had to remember"
     (release.yml). That was identified, automated for the formulas, and the
     one document a tester actually reads was left on the unprotected side of
     the line — which is why it cited a 0.5.0 scope document from a 0.6.3+
     release.

     NO SUBSTITUTIONS. Deliberately: this file carries no version, no sha256
     and no tag, so `sync-tap.sh`'s rewrite step does not touch it and
     release.yml's placeholder check does not cover it. That check exists to
     prove a substitution did not silently no-op; with nothing to substitute
     there is nothing for it to prove. If you ever add version-dependent text
     here, it needs the guarantee the formulas have — the value comes from the
     release or the file does not get written — and it must not be
     hand-maintained.

     Do NOT confuse this with packaging/homebrew/README.md, which is internal
     packaging notes for us and is not published. -->

# makinaX Agent Kit — Homebrew tap

Prebuilt binaries for the **makinaX Agent Kit** (`makinax-mcp`), an MCP server
that gives AI agents governed access to a Gnosis Safe running a
`MakinaLiteModule` strategy.

This repository contains **no source** — only the Homebrew formulas and the
release artifacts they point at.

## Install

```sh
brew install makinahq/makinax-mcp/makinax-mcp
```

Reporting only, with signing code compiled out rather than disabled:

```sh
brew install makinahq/makinax-mcp/makinax-mcp-readonly
```

The two conflict — they install the same binary name. Pick one.

## First run

```sh
makinax onboard
```

That is the starting point: it walks the whole flow, asks for your Safe, and
tells you who must act next at every step. The individual commands below exist
for when you already know what you want.

```sh
makinax --version     # variant + version + commit
makinax --help        # every command
```

**Two names, one binary.** `makinax` is what a person types; `makinax-mcp` is
the name an MCP host launches. The formula installs both — `makinax` is a
symlink — so `makinax onboard` and the MCP registration refer to the same
program.

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
makinax self-update              # latest release
makinax self-update --tag vX.Y.Z # a specific one
makinax self-update --rollback   # restore the previous binary
```

It downloads from this repository over plain HTTPS — no GitHub account, no
`gh`, no credentials. It verifies the checksum and the staged binary's reported
version before swapping anything, keeps the previous binary as `*.prev`, and
**never compiles**.

## Platforms

**This tap serves macOS arm64 (Apple Silicon).** That is what `brew install`
here installs and the only target it can install correctly.

Linux tarballs (`x86_64-unknown-linux-gnu`) are published with each release and
can be downloaded and unpacked directly. Two things to know before you do:

- they require **glibc ≥ 2.39**, so Ubuntu 22.04 and Debian 12 cannot run them;
- there is **no `aarch64-unknown-linux-gnu` build**.

**Do not install via this tap on Linux or Intel macOS.** The formula will
download the macOS-arm64 tarball and install a binary that cannot run on your
machine — it succeeds and leaves you with something broken rather than
refusing.

The binaries are **not signed or notarized**, so first launch on macOS may need
Gatekeeper approval (System Settings → Privacy & Security).
