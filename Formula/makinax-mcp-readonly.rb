# Source of truth for the MakinaHQ/homebrew-tap formula.
#
# Do NOT hand-edit the version or sha256: run ./sync-tap.sh <tag>, which reads
# the release's SHA256SUMS and rewrites both formulas, then copy them to the
# tap. A hand-maintained checksum is a checksum that silently goes stale --
# this file sat at 0.1.0-rc.1 against a 0.4.0 codebase.
class MakinaxMcpReadonly < Formula
  desc "Reporting-only MCP server for Makina-Lite machines (no signing capability compiled in)"
  homepage "https://github.com/MakinaHQ/homebrew-makinax-mcp"
  version "0.6.4"

  # url/sha256 are declared UNCONDITIONALLY. They used to sit inside
  # `if OS.mac? && Hardware::CPU.arm?`, which meant that whenever that
  # expression was false — or could not be EVALUATED — the formula had no url
  # at all, and Homebrew rejected the FORMULA rather than the platform:
  #
  #     Error: makinahq/makinax-mcp/makinax-mcp: formula requires at least a URL
  #
  # A tester hit exactly that: their Homebrew could not parse macOS `26.2` and
  # raised `MacOSVersion::Error` while evaluating the condition. Their broken
  # brew was not our bug; turning it into an error that points at MakinaHQ's
  # packaging was. `brew tap` was broken on the stable channel with every
  # version field correct.
  #
  # A conditional may narrow or override what is served. It must never be the
  # only place a url is declared.
  url "https://github.com/MakinaHQ/homebrew-makinax-mcp/releases/download/v#{version}/makinax-mcp-readonly-aarch64-apple-darwin.tar.xz"
  sha256 "7e0db4469f58373098b1249ea0ff45bc282aaf949e0e3816485e65a526bd8ad4" # filled by sync-tap.sh from the release's SHA256SUMS

  # NOT ADDED HERE: the release also publishes x86_64 Linux assets, which no
  # formula references. Adding them means teaching sync-tap.sh to fill a SECOND
  # (url, sha256) pair from a different asset name, and widening that fill
  # logic inside a fix that unblocks `brew tap` on the stable channel is the
  # wrong risk to take — a mis-filled checksum fails as a corrupted download.
  # Filed separately; the tap serves macOS today exactly as it did before.

  conflicts_with "makinax-mcp",
    because: "both install a binary named `makinax-mcp`"

  # Hard runtime dependency: the documented bootstrap (compose_root ->
  # ensure_integrations) shells out to `git clone/fetch/checkout` for the
  # pinned makina-integrations ref. On a fresh Mac with no Xcode CLT the
  # bare `git` stub pops a GUI installer mid-tool-call; declaring it here
  # makes brew install a real one up front.
  depends_on "git"

  # Refuse a platform this tarball cannot run on — AT INSTALL TIME, and the
  # timing is the whole design. See the long note in `makinax-mcp.rb`: cc-156
  # removed a LOAD-time conditional because a condition that could not be
  # evaluated left the formula with no url and broke `brew tap` itself; the
  # cost was that `brew install` on Linux or Intel started succeeding and
  # installing an unrunnable binary. A formula must LOAD everywhere and need
  # only INSTALL where it works.
  def install
    unless OS.mac? && Hardware::CPU.arm?
      odie <<~EOS
        makinax-mcp-readonly is packaged for macOS on Apple Silicon (arm64) only,
        and this machine is not that. Refusing rather than installing a binary
        that cannot run here.

        Linux x86_64: the release publishes
        `makinax-mcp-readonly-x86_64-unknown-linux-gnu.tar.xz`. Download and
        unpack it directly — it needs glibc 2.39 or newer, so Ubuntu 22.04 and
        Debian 12 will not run it.

        Linux arm64 and Intel macOS: no build is published today.

        Releases: https://github.com/MakinaHQ/homebrew-makinax-mcp/releases
      EOS
    end
    # The artifact carries the DISTINCT name so `tar -tf` says which variant
    # you have without executing it; the installed COMMAND is `makinax-mcp`
    # for both variants, because that is what every skill, the README, and
    # MCP host configs invoke.
    bin.install "makinax-mcp-readonly" => "makinax-mcp"
    # `makinax` is the CLI name a person types (`makinax onboard`,
    # `makinax <tool>`); `makinax-mcp` is what an MCP host launches. One
    # binary — dispatch does not depend on argv[0]. See `makinax --help`.
    bin.install_symlink bin/"makinax-mcp" => "makinax"
    # The files the product points at, installed so those pointers resolve
    # rather than leading into a private repo.
    pkgshare.install Dir["share/*"]
  end

  def caveats
    <<~EOS
      Read-only build: strictly reporting — no signing capability is compiled
      in, and the server refuses to start if key material is configured.

      Start here:
        makinax onboard     # where you are and what remains — resumable; on
                            # first run it asks for your Safe and writes the config
        makinax --help      # every command, incl. `makinax <tool> [--args…]`

      References:
        #{opt_pkgshare}/skills/makina-portfolio/SKILL.md
        #{opt_pkgshare}/example.config.toml     # every option, annotated
        #{opt_pkgshare}/package-manifest-schema.md  # the manifest contract

      After `brew upgrade`: restart/reconnect your MCP host — a running
      server keeps serving the OLD build until it is restarted. To catch a
      stale server, compare the health_check tool's `version` (the RUNNING
      image) against `makinax --version` (what is on disk).

      Set `operator_address` in your [safes.<name>] block — read-only builds
      have no signer to derive it from, and position valuation is
      operator-gated on-chain.
    EOS
  end

  test do
    assert_match "[read-only]", shell_output("#{bin}/makinax-mcp --version")
    assert_match "makinax onboard", shell_output("#{bin}/makinax --help")
  end
end
