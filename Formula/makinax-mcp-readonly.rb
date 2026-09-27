# Source of truth for the MakinaHQ/homebrew-makinax-mcp tap formula.
#
# Do NOT hand-edit the version or sha256: release.yml runs ./sync-tap.sh <tag>,
# which reads the release's SHA256SUMS and rewrites both formulas, then commits
# them to the tap. A hand-maintained checksum goes stale silently.
class MakinaxMcpReadonly < Formula
  desc "MCP server for reading a makinaX module (no signing code compiled in)"
  homepage "https://github.com/MakinaHQ/homebrew-makinax-mcp"
  version "0.8.0"

  # url/sha256 are declared unconditionally; see makinax-mcp.rb.
  url "https://github.com/MakinaHQ/homebrew-makinax-mcp/releases/download/v#{version}/makinax-mcp-readonly-aarch64-apple-darwin.tar.xz"
  sha256 "73f785b26d9f6db71852482542cfbf7ed073a69ffcee2aa42e0cdb06e118a674" # filled by sync-tap.sh from the release's SHA256SUMS

  conflicts_with "makinax-mcp",
    because: "both install a binary named `makinax-mcp`"

  def install
    unless OS.mac? && Hardware::CPU.arm?
      odie <<~EOS
        makinax-mcp-readonly is packaged for macOS on Apple Silicon (arm64) only,
        and this machine is not that. Refusing rather than installing a binary
        that cannot run here.

        Linux x86_64: the release publishes
        `makinax-mcp-readonly-x86_64-unknown-linux-gnu.tar.xz`. Download and
        unpack it directly. It needs glibc 2.39 or newer, so Ubuntu 22.04 and
        Debian 12 will not run it.

        Linux arm64 and Intel macOS: no build is published today.

        Releases: https://github.com/MakinaHQ/homebrew-makinax-mcp/releases
      EOS
    end
    # The tarball names the variant (`tar -tf` shows which one you have); the
    # installed command is `makinax-mcp` for both, which is what MCP host
    # configs and the skill invoke.
    bin.install "makinax-mcp-readonly" => "makinax-mcp"
    # The agent skill that describes the tools.
    pkgshare.install Dir["share/*"]
  end

  def caveats
    <<~EOS
      Read-only build: reads, builds, proves and simulates (with eth_call)
      calls to a makinaX module, and encodes owner calls for the Safe owners.
      There is no execute_call, and no signing code is compiled in.

      Config: ~/.config/makinax/config.toml, or pass --config <path>.

      Register the server with your MCP host:
        "makinax": { "command": "#{opt_bin}/makinax-mcp" }

      The agent skill:
        #{opt_pkgshare}/skills/makinax/SKILL.md

      After `brew upgrade`, restart your MCP host: a running server keeps
      serving the old build until it is restarted.
    EOS
  end

  test do
    assert_match "[read-only]", shell_output("#{bin}/makinax-mcp --version")
    refute_match "execute_call", shell_output("#{bin}/makinax-mcp tools")
  end
end
