# Source of truth for the MakinaHQ/homebrew-tap formula.
#
# Do NOT hand-edit the version or sha256: run ./sync-tap.sh <tag>, which reads
# the release's SHA256SUMS and rewrites both formulas, then copy them to the
# tap. A hand-maintained checksum is a checksum that silently goes stale --
# this file sat at 0.1.0-rc.1 against a 0.4.0 codebase.
class MakinaxMcp < Formula
  desc "Mandate-governed MCP server for Makina-Lite machines (read-write build)"
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
  url "https://github.com/MakinaHQ/homebrew-makinax-mcp/releases/download/v#{version}/makinax-mcp-aarch64-apple-darwin.tar.xz"
  sha256 "4c61a36c275e0b17afe1d8189ac238cdbd68f69093324a507f48359d7108c3f5" # filled by sync-tap.sh from the release's SHA256SUMS

  # NOT ADDED HERE: the release also publishes x86_64 Linux assets, which no
  # formula references. Adding them means teaching sync-tap.sh to fill a SECOND
  # (url, sha256) pair from a different asset name, and widening that fill
  # logic inside a fix that unblocks `brew tap` on the stable channel is the
  # wrong risk to take — a mis-filled checksum fails as a corrupted download.
  # Filed separately; the tap serves macOS today exactly as it did before.

  conflicts_with "makinax-mcp-readonly",
    because: "both install a binary named `makinax-mcp`"

  # Hard runtime dependency: the documented bootstrap (compose_root ->
  # ensure_integrations) shells out to `git clone/fetch/checkout` for the
  # pinned makina-integrations ref. On a fresh Mac with no Xcode CLT the
  # bare `git` stub pops a GUI installer mid-tool-call; declaring it here
  # makes brew install a real one up front.
  depends_on "git"

  # Refuse a platform this tarball cannot run on — AT INSTALL TIME, and the
  # timing is the whole design.
  #
  # cc-156 removed a load-time conditional (`if OS.mac? && Hardware::CPU.arm?`
  # around url/sha256) because a condition that could not be EVALUATED left the
  # formula with no url and Homebrew rejected the FORMULA rather than the
  # platform — `brew tap` broken on the stable channel with every version field
  # correct. That fix was right and stands: url/sha256 stay unconditional above.
  #
  # Its consequence was this: `brew install` on Linux or Intel began DOWNLOADING
  # the darwin-arm64 tarball and installing a binary that cannot execute. It
  # used to refuse. A refusal is a bad experience; a successful install of a
  # binary that cannot run is a bug report from someone who believes they
  # installed the product.
  #
  # So the refusal moves to where it belongs. A formula must LOAD everywhere —
  # that is what `brew tap`, `brew search` and every dependency walk need — and
  # need only INSTALL where it works. `install` runs on one machine, at a moment
  # when a raised error is the correct outcome anyway, so a check here cannot
  # break tapping the way a class-level one did.
  #
  # NOT SOLVED HERE, deliberately: the release does publish an x86_64 Linux
  # tarball, but it requires glibc >= 2.39 (read from `.gnu.version_r`, not
  # guessed), so Ubuntu 22.04 and Debian 12 cannot run it, and there is no
  # aarch64-linux build at all. Pointing the formula at it would re-create this
  # very defect on every older Linux — "installs something that cannot run",
  # one platform over. Naming the tarball and its floor lets a reader decide;
  # installing it for them would not.
  def install
    unless OS.mac? && Hardware::CPU.arm?
      odie <<~EOS
        makinax-mcp is packaged for macOS on Apple Silicon (arm64) only, and this
        machine is not that. Refusing rather than installing a binary that cannot
        run here.

        Linux x86_64: the release publishes
        `makinax-mcp-x86_64-unknown-linux-gnu.tar.xz`. Download and unpack it
        directly — it needs glibc 2.39 or newer, so Ubuntu 22.04 and Debian 12
        will not run it.

        Linux arm64 and Intel macOS: no build is published today.

        Releases: https://github.com/MakinaHQ/homebrew-makinax-mcp/releases
      EOS
    end
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
