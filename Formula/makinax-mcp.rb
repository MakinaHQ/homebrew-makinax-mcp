# Source of truth for the MakinaHQ/homebrew-makinax-mcp tap formula.
#
# Do NOT hand-edit the version or sha256: release.yml runs ./sync-tap.sh <tag>,
# which reads the release's SHA256SUMS and rewrites both formulas, then commits
# them to the tap. A hand-maintained checksum goes stale silently.
class MakinaxMcp < Formula
  desc "MCP server for operating a makinaX module (read-write build)"
  homepage "https://github.com/MakinaHQ/homebrew-makinax-mcp"
  version "0.8.0"

  # url/sha256 are declared unconditionally. A url declared only inside a
  # platform conditional leaves the formula with no url when that condition
  # cannot be evaluated, and Homebrew then rejects the formula itself, which
  # breaks `brew tap`. The platform check lives in `install` instead.
  url "https://github.com/MakinaHQ/homebrew-makinax-mcp/releases/download/v#{version}/makinax-mcp-aarch64-apple-darwin.tar.xz"
  sha256 "3e8f81c91ec8dee32a82f1fd40885a1bef22bbd60b66b801da0e10f61366b254" # filled by sync-tap.sh from the release's SHA256SUMS

  conflicts_with "makinax-mcp-readonly",
    because: "both install a binary named `makinax-mcp`"

  # A formula must load everywhere (`brew tap`, `brew search` and dependency
  # walks need that) and install only where the tarball runs.
  def install
    unless OS.mac? && Hardware::CPU.arm?
      odie <<~EOS
        makinax-mcp is packaged for macOS on Apple Silicon (arm64) only, and this
        machine is not that. Refusing rather than installing a binary that cannot
        run here.

        Linux x86_64: the release publishes
        `makinax-mcp-x86_64-unknown-linux-gnu.tar.xz`. Download and unpack it
        directly. It needs glibc 2.39 or newer, so Ubuntu 22.04 and Debian 12
        will not run it.

        Linux arm64 and Intel macOS: no build is published today.

        Releases: https://github.com/MakinaHQ/homebrew-makinax-mcp/releases
      EOS
    end
    bin.install "makinax-mcp"
    # The agent skill that describes the tools.
    pkgshare.install Dir["share/*"]
  end

  def caveats
    <<~EOS
      Read-write build: reads, builds, proves, simulates and sends operator
      calls to a makinaX module, and encodes owner calls for the Safe owners.
      Sending needs a [signer] in the config (keystore or GCP KMS).
      Fork simulation needs foundry's anvil, and Base Anvil on Base
      (set fork.base_anvil_path).

      Config: ~/.config/makinax/config.toml, or pass --config <path>.

      Register the server with your MCP host:
        "makinax": { "command": "#{opt_bin}/makinax-mcp" }

      The agent skill:
        #{opt_pkgshare}/skills/makinax/SKILL.md

      After `brew upgrade`, restart your MCP host: a running server keeps
      serving the old build until it is restarted.

      Read-only? Install makinahq/makinax-mcp/makinax-mcp-readonly.
    EOS
  end

  test do
    assert_match "[read-write]", shell_output("#{bin}/makinax-mcp --version")
    assert_match "execute_call", shell_output("#{bin}/makinax-mcp tools")
  end
end
