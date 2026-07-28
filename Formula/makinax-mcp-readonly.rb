# Source of truth for the MakinaHQ/homebrew-tap formula.
#
# Do NOT hand-edit the version or sha256: run ./sync-tap.sh <tag>, which reads
# the release's SHA256SUMS and rewrites both formulas, then copy them to the
# tap. A hand-maintained checksum is a checksum that silently goes stale --
# this file sat at 0.1.0-rc.1 against a 0.4.0 codebase.
class MakinaxMcpReadonly < Formula
  desc "Reporting-only MCP server for Makina-Lite machines (no signing capability compiled in)"
  homepage "https://github.com/MakinaHQ/homebrew-makinax"
  version "0.5.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/homebrew-makinax/releases/download/v#{version}/makinax-mcp-readonly-aarch64-apple-darwin.tar.xz"
    sha256 "7efa21b8e94e56dbe67592659c9951973f55df089125e874b82d4e1d39bf2509" # filled by sync-tap.sh from the release's SHA256SUMS
  end

  conflicts_with "makinax-mcp",
    because: "both install a binary named `makinax-mcp`"

  def install
    bin.install "makinax-mcp"
  end

  def caveats
    <<~EOS
      Read-only build: strictly reporting — no signing capability is compiled
      in, and the server refuses to start if key material is configured.
      Setup: skills/makina-portfolio in the repo (config bootstrap section).
    EOS
  end

  test do
    assert_match "[read-only]", shell_output("#{bin}/makinax-mcp --version")
  end
end
