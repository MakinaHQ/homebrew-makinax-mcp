# Source of truth for the MakinaHQ/homebrew-tap formula.
#
# Do NOT hand-edit the version or sha256: run ./sync-tap.sh <tag>, which reads
# the release's SHA256SUMS and rewrites both formulas, then copy them to the
# tap. A hand-maintained checksum is a checksum that silently goes stale --
# this file sat at 0.1.0-rc.1 against a 0.4.0 codebase.
class MakinaxMcp < Formula
  desc "Mandate-governed MCP server for Makina-Lite machines (read-write build)"
  homepage "https://github.com/MakinaHQ/homebrew-makinax"
  version "0.5.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/homebrew-makinax/releases/download/v#{version}/makinax-mcp-aarch64-apple-darwin.tar.xz"
    sha256 "c4ba69c97d3c3ab739a980920b0fcaad7d876f3187c595b01691e938e9fb900d" # filled by sync-tap.sh from the release's SHA256SUMS
  end

  conflicts_with "makinax-mcp-readonly",
    because: "both install a binary named `makinax-mcp`"

  def install
    bin.install "makinax-mcp"
    bin.install "makinax-watchdog"
  end

  def caveats
    <<~EOS
      Write build: execution requires a signer, a mandate, and foundry (anvil)
      for pre-execution fork simulation. Also installs makinax-watchdog —
      the independent loss circuit breaker (separate guardian key; run it on
      a different host when you can). Start with the onboarding skill in the
      repo (skills/makina-onboarding). Reporting-only? Install
      makinahq/tap/makinax-mcp-readonly instead.
    EOS
  end

  test do
    assert_match "[read-write]", shell_output("#{bin}/makinax-mcp --version")
  end
end
