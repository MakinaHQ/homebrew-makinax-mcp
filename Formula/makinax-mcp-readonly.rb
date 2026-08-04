# Source of truth for the MakinaHQ/homebrew-tap formula.
#
# Do NOT hand-edit the version or sha256: run ./sync-tap.sh <tag>, which reads
# the release's SHA256SUMS and rewrites both formulas, then copy them to the
# tap. A hand-maintained checksum is a checksum that silently goes stale --
# this file sat at 0.1.0-rc.1 against a 0.4.0 codebase.
class MakinaxMcpReadonly < Formula
  desc "Reporting-only MCP server for Makina-Lite machines (no signing capability compiled in)"
  homepage "https://github.com/MakinaHQ/homebrew-makinax-mcp"
  version "0.5.2-rc.16"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/homebrew-makinax-mcp/releases/download/v#{version}/makinax-mcp-readonly-aarch64-apple-darwin.tar.xz"
    sha256 "c4c21c873b47d1b0b9bd643e2189e1aa2d6e42d0658f97ed5f03a89714e06114" # filled by sync-tap.sh from the release's SHA256SUMS
  end

  conflicts_with "makinax-mcp",
    because: "both install a binary named `makinax-mcp`"

  def install
    bin.install "makinax-mcp"
    # The files the product points at, installed so those pointers resolve
    # rather than leading into a private repo.
    pkgshare.install Dir["share/*"]
  end

  def caveats
    <<~EOS
      Read-only build: strictly reporting — no signing capability is compiled
      in, and the server refuses to start if key material is configured.

      Start here:
        makinax-mcp init          # writes ~/.config/makinax/config.toml
        #{opt_pkgshare}/skills/makina-portfolio/SKILL.md
        #{opt_pkgshare}/example.config.toml     # every option, annotated
        #{opt_pkgshare}/package-manifest-schema.md  # the manifest contract

      Set `operator_address` in your [safes.<name>] block — read-only builds
      have no signer to derive it from, and position valuation is
      operator-gated on-chain.
    EOS
  end

  test do
    assert_match "[read-only]", shell_output("#{bin}/makinax-mcp --version")
  end
end
