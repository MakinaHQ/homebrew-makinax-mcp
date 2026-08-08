# Source of truth for the MakinaHQ/homebrew-tap formula.
#
# Do NOT hand-edit the version or sha256: run ./sync-tap.sh <tag>, which reads
# the release's SHA256SUMS and rewrites both formulas, then copy them to the
# tap. A hand-maintained checksum is a checksum that silently goes stale --
# this file sat at 0.1.0-rc.1 against a 0.4.0 codebase.
class MakinaxMcp < Formula
  desc "Mandate-governed MCP server for Makina-Lite machines (read-write build)"
  homepage "https://github.com/MakinaHQ/homebrew-makinax-mcp"
  version "0.5.2-rc.28"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/homebrew-makinax-mcp/releases/download/v#{version}/makinax-mcp-aarch64-apple-darwin.tar.xz"
    sha256 "46b2bf1c87a0b026114ca365a9a2d0315100e5993febce537bf9689ba2a55bea" # filled by sync-tap.sh from the release's SHA256SUMS
  end

  conflicts_with "makinax-mcp-readonly",
    because: "both install a binary named `makinax-mcp`"

  def install
    bin.install "makinax-mcp"
    bin.install "makinax-watchdog"
    # `makinax` is the CLI name a person types (`makinax onboard`,
    # `makinax <tool>`); `makinax-mcp` is what an MCP host launches. One
    # binary — dispatch does not depend on argv[0]. See `makinax --help`.
    bin.install_symlink bin/"makinax-mcp" => "makinax"
    # The files the product points at, installed so those pointers resolve.
    # `example.config.toml` is cited by the config `init` writes, the skills
    # by these caveats, `watchdog.example.toml` by the onboarding skill.
    # Without them the references lead into a private repo.
    pkgshare.install Dir["share/*"]
  end

  def caveats
    <<~EOS
      Write build: execution requires a signer, a mandate, and foundry (anvil)
      for pre-execution fork simulation. Also installs makinax-watchdog —
      the independent loss circuit breaker (separate guardian key; run it on
      a different host when you can).

      Start here:
        makinax onboard     # where you are, who must act, and the next action —
                            # resumable; on first run it asks for your Safe and
                            # chain and writes the config itself
        makinax --help      # every command, incl. `makinax <tool> [--args…]`

      References:
        #{opt_pkgshare}/skills/makina-onboarding/SKILL.md
        #{opt_pkgshare}/example.config.toml     # every option, annotated
        #{opt_pkgshare}/package-manifest-schema.md  # the manifest contract
        #{opt_pkgshare}/watchdog.example.toml   # circuit-breaker config

      After `brew upgrade`: restart/reconnect your MCP host — a running
      server keeps serving the OLD build until it is restarted. To catch a
      stale server, compare the health_check tool's `version` (the RUNNING
      image) against `makinax --version` (what is on disk).

      A newly provisioned Safe has NO instruction root, and that is normal —
      one cannot exist before you compose it. The Kit boots "unrooted" and
      offers the path out: install a package, compose_root, then the Safe
      OWNER signs setAllowedInstrRoot.

      Reporting-only? Install makinahq/makinax-mcp/makinax-mcp-readonly.
    EOS
  end

  test do
    assert_match "[read-write]", shell_output("#{bin}/makinax-mcp --version")
    # The documented entry point exists under the documented name.
    assert_match "makinax onboard", shell_output("#{bin}/makinax --help")
  end
end
