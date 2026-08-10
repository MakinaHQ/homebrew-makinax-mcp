# Source of truth for the MakinaHQ/homebrew-tap formula.
#
# Do NOT hand-edit the version or sha256: run ./sync-tap.sh <tag>, which reads
# the release's SHA256SUMS and rewrites both formulas, then copy them to the
# tap. A hand-maintained checksum is a checksum that silently goes stale --
# this file sat at 0.1.0-rc.1 against a 0.4.0 codebase.
class MakinaxMcpReadonly < Formula
  desc "Reporting-only MCP server for Makina-Lite machines (no signing capability compiled in)"
  homepage "https://github.com/MakinaHQ/homebrew-makinax-mcp"
  version "0.6.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/homebrew-makinax-mcp/releases/download/v#{version}/makinax-mcp-readonly-aarch64-apple-darwin.tar.xz"
    sha256 "e69fd9bf8f71843c3818970c48aad9caee99f37e8c3aac5c87835fb0ab0d6d2c" # filled by sync-tap.sh from the release's SHA256SUMS
  end

  conflicts_with "makinax-mcp",
    because: "both install a binary named `makinax-mcp`"

  # Hard runtime dependency: the documented bootstrap (compose_root ->
  # ensure_integrations) shells out to `git clone/fetch/checkout` for the
  # pinned makina-integrations ref. On a fresh Mac with no Xcode CLT the
  # bare `git` stub pops a GUI installer mid-tool-call; declaring it here
  # makes brew install a real one up front.
  depends_on "git"

  def install
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
