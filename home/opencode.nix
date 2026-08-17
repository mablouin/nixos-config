{ config, lib, pkgs, ... }:

let
  # nixpkgs' own opencode build corrupts the embedded Bun payload's segment
  # order, causing a SIGSEGV on every invocation (upstream anomalyco/opencode#26846).
  # Fetching the official release tarball unmodified (dontFixup, no patchelf)
  # and relying on nix-ld (programs.nix-ld.enable in configuration.nix) for the
  # interpreter avoids the corruption entirely. Bump version + sha256 to upgrade.
  opencode = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "opencode";
    version = "1.18.18";

    src = pkgs.fetchurl {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
      sha256 = "1bravfgirc3nmkb86kd21pq8hw6s1h69ia05k5k571cb84ic5p8c";
    };

    sourceRoot = ".";
    dontFixup = true;

    installPhase = ''
      install -Dm755 opencode $out/bin/opencode
    '';
  };

  pluginInstallCommands = lib.concatMapStringsSep "\n" (plugin: let
    parts = lib.splitString "@" plugin;
  in
    if builtins.length parts != 2 then
      throw "OpenCode marketplace plugin must use plugin@marketplace format: ${plugin}"
    else let
      pluginName = builtins.elemAt parts 0;
      marketplaceName = builtins.elemAt parts 1;
      marketplaceRoot = builtins.getAttr marketplaceName config.opencode.marketplaces;
    in ''
      install_plugin "${marketplaceRoot}" "${pluginName}"
    '') config.opencode.marketplacePlugins;

  installMarketplaceSkills = pkgs.writeShellScript "install-opencode-marketplace-skills" ''
    set -eu
    target="${config.xdg.configHome}/opencode/skills"
    state="${config.xdg.stateHome}/opencode/marketplace-skills"

    mkdir -p "$target"
    mkdir -p "$(dirname "$state")"

    if [ -f "$state" ]; then
      while IFS= read -r skill; do
        rm -f "$target/$skill"
      done < "$state"
    fi
    : > "$state"

    install_plugin() {
      marketplace="$1"
      plugin="$2"
      plugin_dir="$(find "$marketplace/plugins" -type d -name "$plugin" -print -quit)"

      if [ -z "$plugin_dir" ] || [ ! -d "$plugin_dir/skills" ]; then
        printf 'OpenCode marketplace plugin has no skills directory: %s@%s\n' "$plugin" "$marketplace" >&2
        exit 1
      fi

      for skill_dir in "$plugin_dir"/skills/*; do
        [ -f "$skill_dir/SKILL.md" ] || continue
        skill="$(basename "$skill_dir")"
        ln -sfnT "$skill_dir" "$target/$skill"
        printf '%s\n' "$skill" >> "$state"
      done
    }

    ${pluginInstallCommands}
  '';
in
{
  options.opencode = {
    marketplaces = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Named local AI marketplace checkouts.";
    };

    marketplacePlugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Marketplace plugins using the plugin@marketplace format.";
    };
  };

  config = {
    home.packages = [ opencode ];
    home.activation.opencodeMarketplaceSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${installMarketplaceSkills}
    '';
  };
}
